import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/screens/screen/home_views/setting_view.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/about.dart';
import 'package:beats_music/utils/toast_utils.dart';
import 'package:beats_music/services/auth_service.dart';
import 'package:beats_music/routes_and_consts/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/profile_edit_screen.dart';

import 'package:beats_music/screens/widgets/privacy_policy_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isGuest = user == null;

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
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (isGuest) {
                       context.push(GlobalRoutes.LOGIN);
                    } else {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                       );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30), // Circle for user
                        image: user?.photoURL != null
                            ? DecorationImage(
                                image: NetworkImage(user!.photoURL!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.photoURL == null
                          ? const Icon(
                              MingCute.user_4_fill,
                              size: 32,
                              color: Default_Theme.spotifyGreen,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Sign in to sync data',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
                      title: isGuest ? 'Sign In / Account' : 'Profile',
                      onTap: () {
                         Navigator.pop(context); // Close drawer
                         if (isGuest) {
                           context.push(GlobalRoutes.LOGIN);
                         } else {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                           );
                         }
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                        );
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
      },
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
