import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/screens/auth/login_screen.dart';
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

class _PermissionScreenState extends State<PermissionScreen> {
  bool _notificationGranted = false;
  bool _storageGranted = false;
  bool _batteryGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notificationStatus = await Permission.notification.status;
    final storageStatus = await Permission.audio.status; // Android 13+ use audio
    
    if (mounted) {
      setState(() {
        _notificationGranted = notificationStatus.isGranted;
        _storageGranted = storageStatus.isGranted;
      });
    }
  }

  Future<void> _requestPermission(Permission permission, Function(bool) onResult) async {
    final status = await permission.request();
    onResult(status.isGranted);
  }

  Future<void> _continue() async {
    if (_storageGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_permission', true);
      
      if (mounted) {
        context.goNamed(RoutePaths.loginScreen);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Music permission is required to play songs!")),
      );
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
                onTap: () => _requestPermission(Permission.notification, (val) {
                  setState(() => _notificationGranted = val);
                }),
              ),
              
              const SizedBox(height: 16),
              
                _buildPermissionTile(
                icon: MingCute.music_fill,
                title: "Music & Audio",
                subtitle: "To access and play your local music files.",
                isGranted: _storageGranted,
                onTap: () async {
                  // Android 13+ (SDK 33) uses Permission.audio
                  // Older versions use Permission.storage
                  if (await Permission.audio.request().isGranted || 
                      await Permission.storage.request().isGranted) {
                    setState(() => _storageGranted = true);
                  } else {
                    openAppSettings();
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
               _buildPermissionTile(
                icon: MingCute.battery_fill,
                title: "Battery",
                subtitle: "Disable optimization for uninterrupted background play.",
                isGranted: _batteryGranted,
                onTap: () async {
                   final status = await Permission.ignoreBatteryOptimizations.request();
                   if (status.isGranted) {
                     setState(() => _batteryGranted = true);
                   } else {
                     openAppSettings();
                   }
                },
              ),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Default_Theme.accentColor2,
                    foregroundColor: Default_Theme.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
          color: Colors.white.withOpacity(0.05),
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
                color: isGranted ? Default_Theme.accentColor2.withOpacity(0.2) : Colors.white.withOpacity(0.1),
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
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isGranted)
              const Icon(MingCute.check_circle_fill, color: Default_Theme.accentColor2)
            else
              Text(
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
