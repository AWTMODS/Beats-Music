package com.beats.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioDeviceCallback
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val INSTALLER_CHANNEL = "com.beats.app/package_installer"
    private val AUDIO_EVENTS_CHANNEL = "com.beats.app/audio_events"

    private var eventSink: EventChannel.EventSink? = null
    private var volumeReceiver: BroadcastReceiver? = null
    private var audioDeviceCallback: AudioDeviceCallback? = null
    private var audioManager: AudioManager? = null
    private var lastMutedState: Boolean? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INSTALLER_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath.isNullOrEmpty()) {
                    result.error("INVALID_PATH", "File path is empty", null)
                    return@setMethodCallHandler
                }
                val file = File(filePath)
                if (!file.exists()) {
                    result.error("FILE_NOT_FOUND", "File not found at $filePath", null)
                    return@setMethodCallHandler
                }
                try {
                    val contentUri: Uri = FileProvider.getUriForFile(
                        applicationContext,
                        "${applicationContext.packageName}.fileprovider",
                        file
                    )
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(contentUri, "application/vnd.android.package-archive")
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("INSTALL_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_EVENTS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startAudioListeners()
                }

                override fun onCancel(arguments: Any?) {
                    stopAudioListeners()
                    eventSink = null
                }
            }
        )
    }

    private fun startAudioListeners() {
        val mgr = getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return
        audioManager = mgr
        lastMutedState = mgr.getStreamVolume(AudioManager.STREAM_MUSIC) == 0

        if (volumeReceiver == null) {
            val receiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context?, intent: Intent?) {
                    if (intent?.action != "android.media.VOLUME_CHANGED_ACTION") return
                    val streamType = intent.getIntExtra("android.media.EXTRA_VOLUME_STREAM_TYPE", -1)
                    if (streamType != AudioManager.STREAM_MUSIC && streamType != -1) return
                    val isMuted = mgr.getStreamVolume(AudioManager.STREAM_MUSIC) == 0
                    if (isMuted && lastMutedState != true) {
                        eventSink?.success("muted")
                    }
                    lastMutedState = isMuted
                }
            }
            val filter = IntentFilter("android.media.VOLUME_CHANGED_ACTION")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(receiver, filter)
            }
            volumeReceiver = receiver
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && audioDeviceCallback == null) {
            val callback = object : AudioDeviceCallback() {
                private var initialized = false

                override fun onAudioDevicesAdded(addedDevices: Array<out AudioDeviceInfo>?) {
                    // Skip the initial callback fired immediately on registration.
                    if (!initialized) {
                        initialized = true
                        return
                    }
                    val hasBluetooth = addedDevices?.any { dev ->
                        dev.isSink && (
                            dev.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                                    dev.type == AudioDeviceInfo.TYPE_BLE_HEADSET)
                        )
                    } == true
                    if (hasBluetooth) {
                        eventSink?.success("bluetooth_connected")
                    }
                }
            }
            mgr.registerAudioDeviceCallback(callback, Handler(Looper.getMainLooper()))
            audioDeviceCallback = callback
        }
    }

    private fun stopAudioListeners() {
        volumeReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: Exception) {}
            volumeReceiver = null
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            audioDeviceCallback?.let {
                try {
                    audioManager?.unregisterAudioDeviceCallback(it)
                } catch (_: Exception) {}
                audioDeviceCallback = null
            }
        }
    }

    override fun onDestroy() {
        stopAudioListeners()
        super.onDestroy()
    }
}
