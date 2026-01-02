// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:beats_music/screens/screen/home_views/setting_views/about.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/appui_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/storage_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/country_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/download_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/lastfm_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/player_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/updates_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/donate_setting.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/cloud_sync_setting.dart';
import 'package:beats_music/screens/screen/equalizer_screen.dart';
import 'package:beats_music/services/equalizer_service.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/profile_edit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';


class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final isLoggedIn = user != null && !user.isAnonymous;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text(
          'Settings',
          style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Card (New)
          if (isLoggedIn)
            _buildProfileCard(user),
          if (isLoggedIn)
            const SizedBox(height: 24),
            
          _buildSectionHeader("Playback"),
          _buildSectionContainer([
            settingListTile(
                title: "Playback Settings",
                subtitle: "Stream quality, Auto Play, etc.",
                icon: MingCute.airpods_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlayerSettings(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("Appearance"),
          _buildSectionContainer([
            settingListTile(
                title: "UI Elements & Services",
                subtitle: "Auto slide, Source Engines etc.",
                icon: MingCute.display_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppUISettings(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("General"),
          _buildSectionContainer([
            settingListTile(
                title: "Country & Languages",
                subtitle: "Select your country.",
                icon: MingCute.globe_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CountrySettings(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("Downloads & Offline"),
          _buildSectionContainer([
            settingListTile(
                title: "Downloads",
                subtitle: "Download Path,Download Quality and more...",
                icon: MingCute.folder_download_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DownloadSettings(),
                    ),
                  );
                }),
            const Divider(color: Colors.white10, height: 1),
            settingListTile(
                title: "Storage",
                subtitle: "Backup, Cache, History, Restore and more...",
                icon: MingCute.coin_2_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupSettings(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("Cloud & Sync"),
          _buildSectionContainer([
            settingListTile(
                title: "Cloud Sync",
                subtitle: "Auto-sync, manual sync, and sync settings.",
                icon: MingCute.cloud_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CloudSyncSettings(),
                    ),
                  );
                }),

          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("Integrations"),
          _buildSectionContainer([
            settingListTile(
                title: "Last.FM Settings",
                subtitle: "API Key, Secret, and Scrobbling settings.",
                icon: FontAwesome.lastfm_brand,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LastDotFM(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("Updates"),
          _buildSectionContainer([
            settingListTile(
                title: "Check for Updates",
                subtitle: "Check for new updates",
                icon: MingCute.download_3_fill,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UpdatesSettings(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          _buildSectionHeader("Donate"),
          _buildSectionContainer([
            settingListTile(
                title: "Donate",
                subtitle: "Support the development",
                icon: Icons.favorite,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonateSettings(),
                    ),
                  );
                }),
          ]),
          const SizedBox(height: 20),

          const SizedBox(height: 40),
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
        color: const Color(0xFF1C1C1E), // Dark grey background like iOS/Spotify
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  ListTile settingListTile(
      {required String title,
      required String subtitle,
      required IconData icon,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12)
            .merge(Default_Theme.secondoryTextStyleMedium),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }

  Widget _buildProfileCard(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // Dark grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileEditScreen(),
            ),
          ).then((_) => setState(() {})); // Refresh when coming back
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[800],
              backgroundImage: user.photoURL != null 
                  ? NetworkImage(user.photoURL!) 
                  : null,
              child: user.photoURL == null
                  ? Text(
                      (user.displayName ?? user.email ?? "U")[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    user.displayName ?? 'Music User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'View Profile',
                    style: TextStyle(
                      color: Default_Theme.accentColor2,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
