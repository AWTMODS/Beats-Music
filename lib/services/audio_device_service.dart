import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Information about the current active audio output route.
class AudioOutputInfo {
  final String name;
  final IconData icon;
  final AudioDeviceType type;
  final bool isExternal;

  const AudioOutputInfo({
    required this.name,
    required this.icon,
    required this.type,
    required this.isExternal,
  });

  static const defaultPhone = AudioOutputInfo(
    name: 'This Phone',
    icon: Icons.phone_android_rounded,
    type: AudioDeviceType.builtInSpeaker,
    isExternal: false,
  );

  static const defaultComputer = AudioOutputInfo(
    name: 'This Computer',
    icon: Icons.laptop_rounded,
    type: AudioDeviceType.builtInSpeaker,
    isExternal: false,
  );
}

/// Service that monitors connected audio hardware (Bluetooth headsets, wired
/// headphones, built-in speakers) via [AudioSession] and provides real-time
/// updates for the Spotify-style playback route indicator.
class AudioDeviceService {
  AudioDeviceService._();
  static final AudioDeviceService instance = AudioDeviceService._();

  final _deviceSubject = BehaviorSubject<AudioOutputInfo>.seeded(
    (Platform.isAndroid || Platform.isIOS)
        ? AudioOutputInfo.defaultPhone
        : AudioOutputInfo.defaultComputer,
  );

  Stream<AudioOutputInfo> get outputStream => _deviceSubject.stream;
  AudioOutputInfo get currentOutput => _deviceSubject.value;

  StreamSubscription? _sub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (!Platform.isAndroid && !Platform.isIOS) {
      _deviceSubject.add(AudioOutputInfo.defaultComputer);
      return;
    }

    try {
      final session = await AudioSession.instance;
      _updateDevices(await session.getDevices());

      _sub = session.devicesStream.listen((devices) {
        _updateDevices(devices);
      });
    } catch (e) {
      debugPrint('AudioDeviceService init error: $e');
    }
  }

  void _updateDevices(Set<AudioDevice> devices) {
    final outputs = devices.where((d) => d.isOutput).toList();

    // Priority 1: Bluetooth Headset / Speaker / Earbuds
    final bluetooth = outputs.where((d) =>
        d.type == AudioDeviceType.bluetoothA2dp ||
        d.type == AudioDeviceType.bluetoothSco ||
        d.type == AudioDeviceType.bluetoothLe).firstOrNull;

    if (bluetooth != null) {
      final cleanName = _cleanDeviceName(bluetooth.name);
      _deviceSubject.add(AudioOutputInfo(
        name: cleanName.isNotEmpty ? cleanName : 'Bluetooth Audio',
        icon: Icons.bluetooth_audio_rounded,
        type: bluetooth.type,
        isExternal: true,
      ));
      return;
    }

    // Priority 2: Wired Headset / Headphones / USB-C Audio
    final wired = outputs.where((d) =>
        d.type == AudioDeviceType.wiredHeadset ||
        d.type == AudioDeviceType.wiredHeadphones ||
        d.type == AudioDeviceType.usbAudio).firstOrNull;

    if (wired != null) {
      final name = wired.type == AudioDeviceType.wiredHeadset
          ? 'Wired Headset'
          : 'Wired Headphones';
      _deviceSubject.add(AudioOutputInfo(
        name: name,
        icon: Icons.headphones_rounded,
        type: wired.type,
        isExternal: true,
      ));
      return;
    }

    // Priority 3: Line / HDMI / AirPlay / External
    final external = outputs.where((d) =>
        d.type == AudioDeviceType.hdmi ||
        d.type == AudioDeviceType.hdmiArc ||
        d.type == AudioDeviceType.lineAnalog ||
        d.type == AudioDeviceType.lineDigital ||
        d.type == AudioDeviceType.airPlay ||
        d.type == AudioDeviceType.auxLine).firstOrNull;

    if (external != null) {
      final cleanName = _cleanDeviceName(external.name);
      _deviceSubject.add(AudioOutputInfo(
        name: cleanName.isNotEmpty ? cleanName : 'External Speaker',
        icon: Icons.speaker_rounded,
        type: external.type,
        isExternal: true,
      ));
      return;
    }

    // Priority 4: Built-in speaker / This Phone
    _deviceSubject.add(AudioOutputInfo(
      name: (Platform.isAndroid || Platform.isIOS) ? 'This Phone' : 'This Computer',
      icon: (Platform.isAndroid || Platform.isIOS)
          ? Icons.phone_android_rounded
          : Icons.laptop_rounded,
      type: AudioDeviceType.builtInSpeaker,
      isExternal: false,
    ));
  }

  String _cleanDeviceName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty ||
        trimmed == 'null' ||
        trimmed.toLowerCase() == 'unknown') {
      return '';
    }
    return trimmed;
  }

  void dispose() {
    _sub?.cancel();
    _deviceSubject.close();
  }
}
