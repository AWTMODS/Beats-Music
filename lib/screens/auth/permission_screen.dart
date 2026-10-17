import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _notificationGranted = false;
  bool _storageGranted = false;
  bool _batteryGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final audioGranted = await Permission.audio.status.isGranted;
    final storageGranted = await Permission.storage.status.isGranted;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;
    
    if (mounted) {
      setState(() {
        _notificationGranted = notificationStatus.isGranted;
        _storageGranted = audioGranted || storageGranted;
        _batteryGranted = batteryStatus.isGranted;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      setState(() => _notificationGranted = status.isGranted);
      if (status.isPermanentlyDenied) {
        _showSettingsPrompt("Notification permission");
      }
    }
  }

  Future<void> _requestAudioPermission() async {
    // Android 13+ (API 33+) uses Permission.audio (READ_MEDIA_AUDIO)
    var status = await Permission.audio.request();
    // Android 12 and below uses Permission.storage (READ_EXTERNAL_STORAGE)
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (mounted) {
      setState(() => _storageGranted = status.isGranted);
      if (status.isPermanentlyDenied) {
        _showSettingsPrompt("Music & Audio permission");
      }
    }
  }

  Future<void> _requestBatteryPermission() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    if (mounted) {
      setState(() => _batteryGranted = status.isGranted);
      if (status.isPermanentlyDenied) {
        _showSettingsPrompt("Battery optimization permission");
      }
    }
  }

  void _showSettingsPrompt(String permissionName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$permissionName is disabled. You can enable it in Settings."),
        action: SnackBarAction(
          label: "Settings",
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  Future<void> _continue({bool isSkipping = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_permission', true);
    
    if (mounted) {
      if (isSkipping && !_storageGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Online streaming enabled. You can grant local music access anytime in Settings."),
            duration: Duration(seconds: 3),
          ),
        );
      }
      context.goNamed(RoutePaths.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(MingCute.shield_line, color: Default_Theme.accentColor2, size: 48),
              const SizedBox(height: 16),
              const Text(
                "Permissions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "To provide the best music experience, we need a few permissions.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildPermissionTile(
                icon: MingCute.notification_fill,
                title: "Notifications",
                subtitle: "To show playback controls in the notification bar.",
                isGranted: _notificationGranted,
                onTap: _requestNotificationPermission,
              ),
              
              const SizedBox(height: 16),
              
              _buildPermissionTile(
                icon: MingCute.music_fill,
                title: "Music & Audio",
                subtitle: "To access and play your local music files.",
                isGranted: _storageGranted,
                onTap: _requestAudioPermission,
              ),
              
              const SizedBox(height: 16),
              
              _buildPermissionTile(
                icon: MingCute.battery_fill,
                title: "Battery",
                subtitle: "Disable optimization for uninterrupted background play.",
                isGranted: _batteryGranted,
                onTap: _requestBatteryPermission,
              ),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _continue(isSkipping: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Default_Theme.accentColor2,
                    foregroundColor: Default_Theme.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _storageGranted ? "Continue" : "Continue with Local & Online",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!_storageGranted) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => _continue(isSkipping: true),
                    child: const Text(
                      "Skip for now (Stream Online Only)",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted ? Default_Theme.accentColor2 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGranted ? Default_Theme.accentColor2.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isGranted ? Default_Theme.accentColor2 : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isGranted)
              const Icon(MingCute.check_circle_fill, color: Default_Theme.accentColor2)
            else
              const Text(
                "Allow",
                style: TextStyle(
                  color: Default_Theme.accentColor2,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
