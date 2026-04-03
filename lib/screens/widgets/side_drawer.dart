import 'package:beats_music/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beats_music/screens/screen/home_views/setting_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/about.dart';
import 'package:beats_music/screens/screen/plugin_manager_screen.dart';
import 'package:beats_music/screens/widgets/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/core/theme/app_theme.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final bool isLoggedIn = user != null && !user.isAnonymous;

        return Drawer(
          backgroundColor: Default_Theme.themeColor,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                decoration: const BoxDecoration(
                  color: Default_Theme.successAccent,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: (isLoggedIn && user.photoURL != null)
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: (isLoggedIn && user.photoURL != null)
                          ? null
                          : const Icon(
                              MingCute.user_2_fill,
                              size: 45,
                              color: Default_Theme.successAccent,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isLoggedIn ? (user.displayName ?? "User") : "Guest User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoggedIn ? (user.email ?? "") : "Sign in to sync data",
                      style: const TextStyle(
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
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    _buildDrawerItem(
                      icon: MingCute.plugin_2_fill,
                      label: "Plugin Manager",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PluginManagerScreen()),
                        );
                      },
                    ),
                    if (!isLoggedIn)
                      _buildDrawerItem(
                        icon: MingCute.user_3_fill,
                        label: "Sign In / Account",
                        onTap: () {
                          Navigator.pop(context);
                          context.pushNamed(RoutePaths.loginScreen);
                        },
                      ),
                    _buildDrawerItem(
                      icon: MingCute.settings_3_fill,
                      label: "Settings",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsView()),
                        );
                      },
                    ),
                    const Divider(color: Colors.white10),
                    _buildDrawerItem(
                      icon: MingCute.information_fill,
                      label: "About",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const About()),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      icon: MingCute.shield_fill,
                      label: "Privacy Policy",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen()),
                        );
                      },
                    ),
                    if (isLoggedIn) ...[
                      const Divider(color: Colors.white10),
                      _buildDrawerItem(
                        icon: MingCute.exit_fill,
                        label: "Sign Out",
                        onTap: () async {
                          Navigator.pop(context);
                          await AuthService().signOut();
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Developed with ",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 14,
                    ),
                    Text(
                      " by Aadith",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      horizontalTitleGap: 20,
    );
  }
}
