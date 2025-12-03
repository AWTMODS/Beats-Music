import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/screens/screen/home_views/setting_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/about.dart';
import 'package:beats_music/utils/toast_utils.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Default_Theme.themeColor,
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Default_Theme.spotifyGreen, Color(0xFF1ED760)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    MingCute.music_2_fill,
                    size: 32,
                    color: Default_Theme.spotifyGreen,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Beats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'v1.0.0 (beta)',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Account Section
                _buildDrawerItem(
                  icon: MingCute.user_4_fill,
                  title: 'Account',
                  onTap: () {
                    Navigator.pop(context);
                    ToastUtils.showDefault();
                  },
                ),
                const Divider(color: Default_Theme.cardColor, height: 1),
                
                // Settings
                _buildDrawerItem(
                  icon: MingCute.settings_3_fill,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsView()),
                    );
                  },
                ),
                
                // About
                _buildDrawerItem(
                  icon: MingCute.information_fill,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const About()),
                    );
                  },
                ),
                
                // Privacy Policy
                _buildDrawerItem(
                  icon: MingCute.shield_fill,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    ToastUtils.showComingSoon();
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Developed with ❤️ by Aadith',
              style: TextStyle(
                color: Default_Theme.primaryColor2,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Default_Theme.primaryColor1,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Default_Theme.primaryColor1,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
