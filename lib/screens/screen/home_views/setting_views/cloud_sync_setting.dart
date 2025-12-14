import 'package:beats_music/services/auto_sync_service.dart';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/screens/settings/restore_downloads_screen.dart';

class CloudSyncSettings extends StatefulWidget {
  const CloudSyncSettings({super.key});

  @override
  State<CloudSyncSettings> createState() => _CloudSyncSettingsState();
}

class _CloudSyncSettingsState extends State<CloudSyncSettings> {
  final AutoSyncService _autoSync = AutoSyncService();
  final CloudSyncService _cloudSync = CloudSyncService();
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Auto-sync enabled' : 'Auto-sync disabled'),
        backgroundColor: value ? Colors.green : Colors.orange,
      ),
    );
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
      // Simple format without intl package
      return '${_lastSyncTime!.month}/${_lastSyncTime!.day} ${_lastSyncTime!.hour}:${_lastSyncTime!.minute.toString().padLeft(2, '0')}';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _auth.currentUser != null && !_auth.currentUser!.isAnonymous;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          'Cloud Sync',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isLoggedIn ? MingCute.check_circle_fill : MingCute.close_circle_fill,
                  color: isLoggedIn ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? 'Connected' : 'Not Connected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLoggedIn 
                            ? _auth.currentUser!.email ?? 'Logged in'
                            : 'Sign in to sync your data',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Auto-Sync Toggle
          _buildSectionHeader('Automatic Sync'),
          _buildSectionContainer([
            SwitchListTile(
              value: _autoSyncEnabled,
              onChanged: isLoggedIn ? _toggleAutoSync : null,
              title: const Text(
                'Auto-Sync',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Text(
                _autoSyncEnabled 
                    ? 'Syncs every 5 minutes (saves data automatically)'
                    : 'Disabled (saves mobile data)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              activeColor: Default_Theme.accentColor2,
              activeTrackColor: Default_Theme.accentColor2.withOpacity(0.5),
              secondary: Icon(
                _autoSyncEnabled ? MingCute.refresh_2_fill : MingCute.refresh_2_line,
                color: Colors.white,
              ),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Manual Sync
          _buildSectionHeader('Manual Sync'),
          _buildSectionContainer([
            ListTile(
              leading: _isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(MingCute.upload_3_fill, color: Colors.white),
              title: const Text(
                'Sync Now',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Text(
                'Last synced: ${_formatLastSyncTime()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: _isSyncing || !isLoggedIn ? null : _syncNow,
            ),
          ]),
          
          const SizedBox(height: 24),

          // Restore Data
          _buildSectionHeader('Restore Data'),
          _buildSectionContainer([
            ListTile(
              leading: const Icon(Icons.download_for_offline, color: Colors.white),
              title: const Text(
                'Restore Missing Downloads',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              subtitle: Text(
                'Re-download songs found in your cloud backup',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RestoreDownloadsScreen()),
                );
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // What Gets Synced
          _buildSectionHeader('What Gets Synced'),
          _buildSectionContainer([
            _buildInfoTile(
              icon: MingCute.music_2_fill,
              title: 'User Playlists',
              subtitle: 'All your custom playlists',
            ),
            const Divider(color: Colors.white10, height: 1),
            _buildInfoTile(
              icon: MingCute.heart_fill,
              title: 'Liked Songs',
              subtitle: 'Your favorite tracks',
            ),
            const Divider(color: Colors.white10, height: 1),
            _buildInfoTile(
              icon: MingCute.history_fill,
              title: 'Recently Played',
              subtitle: 'Last 50 tracks',
            ),
            const Divider(color: Colors.white10, height: 1),
            _buildInfoTile(
              icon: MingCute.download_3_fill,
              title: 'Downloads List',
              subtitle: 'Metadata only (for re-download)',
            ),
            const Divider(color: Colors.white10, height: 1),
            _buildInfoTile(
              icon: MingCute.chart_bar_fill,
              title: 'Listening Stats',
              subtitle: 'Top artists, songs & genres',
            ),
          ]),
          
          const SizedBox(height: 32),
          
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  MingCute.information_fill,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Auto-Sync',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When enabled, your data syncs automatically every 5 minutes. Disable to save mobile data.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
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
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
  
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Default_Theme.accentColor2, size: 24),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
    );
  }
}
