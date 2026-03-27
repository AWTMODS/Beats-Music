import 'package:beats_music/services/auto_sync_service.dart';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:beats_music/services/db/sync_adapter.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/restore_downloads_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class CloudSyncSettings extends StatefulWidget {
  const CloudSyncSettings({super.key});

  @override
  State<CloudSyncSettings> createState() => _CloudSyncSettingsState();
}

class _CloudSyncSettingsState extends State<CloudSyncSettings> {
  final AutoSyncService _autoSync = AutoSyncService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _autoSyncEnabled = true;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final enabled = await _autoSync.isAutoSyncEnabled();
    final lastSync = await _autoSync.getLastSyncTime();
    setState(() {
      _autoSyncEnabled = enabled;
      _lastSyncTime = lastSync;
    });
  }
  
  Future<void> _toggleAutoSync(bool value) async {
    await _autoSync.setAutoSyncEnabled(value);
    setState(() {
      _autoSyncEnabled = value;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Auto-sync enabled' : 'Auto-sync disabled'),
          backgroundColor: value ? Colors.green : Colors.orange,
        ),
      );
    }
  }
  
  Future<void> _syncNow() async {
    if (_auth.currentUser == null || _auth.currentUser!.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in required to sync'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSyncing = true;
    });
    
    try {
      await _autoSync.syncNow();
      final lastSync = await _autoSync.getLastSyncTime();
      setState(() {
        _lastSyncTime = lastSync;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sync complete!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }
  
  String _formatLastSyncTime() {
    if (_lastSyncTime == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(_lastSyncTime!);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else {
      return '${_lastSyncTime!.month}/${_lastSyncTime!.day} ${_lastSyncTime!.hour}:${_lastSyncTime!.minute.toString().padLeft(2, '0')}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _auth.currentUser != null && !_auth.currentUser!.isAnonymous;
    
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Cloud Sync',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Account Status Section
              SettingSectionHeader(label: 'Account Status'),
              SettingCard(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SettingIconBox(
                          icon: isLoggedIn ? MingCute.check_circle_fill : MingCute.close_circle_fill,
                          color: isLoggedIn ? Default_Theme.accentColor2 : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoggedIn ? 'Connected' : 'Not Connected',
                                style: Default_Theme.secondoryTextStyleMedium.copyWith(
                                  color: Default_Theme.primaryColor1,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isLoggedIn 
                                    ? _auth.currentUser!.email ?? 'Logged in'
                                    : 'Sign in to sync your data',
                                style: Default_Theme.secondoryTextStyle.copyWith(
                                  color: Default_Theme.primaryColor1.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // Synchronization Section
              SettingSectionHeader(label: 'Synchronization'),
              SettingCard(
                children: [
                  SettingToggleTile(
                    icon: _autoSyncEnabled ? MingCute.refresh_2_fill : MingCute.refresh_2_line,
                    title: 'Auto-Sync',
                    subtitle: _autoSyncEnabled 
                        ? 'Syncs every 5 minutes automatically'
                        : 'Disabled (manual sync only)',
                    value: _autoSyncEnabled,
                    onChanged: isLoggedIn ? _toggleAutoSync : (v) {},
                  ),
                  const SettingDivider(),
                  SettingNavTile(
                    icon: _isSyncing ? MingCute.loading_3_fill : MingCute.upload_3_fill,
                    title: 'Sync Now',
                    subtitle: 'Last synced: ${_formatLastSyncTime()}',
                    onTap: _isSyncing || !isLoggedIn ? () {} : _syncNow,
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
    
              // Data Management Section
              SettingSectionHeader(label: 'Data Management'),
              SettingCard(
                children: [
                  SettingNavTile(
                    icon: MingCute.download_3_fill,
                    title: 'Restore Missing Downloads',
                    subtitle: 'Re-download songs found in cloud',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RestoreDownloadsScreen()),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 28),
              
              // What Gets Synced Info
              SettingSectionHeader(label: 'What Gets Synced'),
              SettingCard(
                children: [
                  _buildInfoItem(MingCute.music_2_fill, 'User Playlists', 'Custom playlists and folders'),
                  const SettingDivider(),
                  _buildInfoItem(MingCute.heart_fill, 'Liked Songs', 'Tracks marked as favorite'),
                  const SettingDivider(),
                  _buildInfoItem(MingCute.history_fill, 'Recently Played', 'Your recent listening history'),
                  const SettingDivider(),
                  _buildInfoItem(MingCute.chart_bar_fill, 'Listening Stats', 'Top artists and songs'),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Default_Theme.accentColor2.withOpacity(0.7), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Default_Theme.secondoryTextStyleMedium.copyWith(
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: Default_Theme.secondoryTextStyle.copyWith(
                    color: Default_Theme.primaryColor1.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
