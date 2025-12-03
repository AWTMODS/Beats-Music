import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/screens/screen/home_views/setting_views/donate_setting.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Default_Theme.primaryColor1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Default_Theme.spotifyGreen,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  MingCute.music_2_fill,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'Beats',
                style: TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Version
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.hasData
                      ? 'v${snapshot.data!.version} (beta)'
                      : 'v1.0.0 (beta)';
                  return Text(
                    version,
                    style: const TextStyle(
                      color: Default_Theme.primaryColor2,
                      fontSize: 16,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              
              // Tagline
              const Text(
                'Your personal music companion',
                style: TextStyle(
                  color: Default_Theme.primaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Developer Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Default_Theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Developed by',
                      style: TextStyle(
                        color: Default_Theme.primaryColor2,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aadith C V',
                      style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Social Links
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: MingCute.github_fill,
                          label: 'GitHub',
                          onTap: () {
                            launchUrl(
                              Uri.parse('https://github.com/AWTMODS'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                        _buildSocialButton(
                          icon: FontAwesome.instagram_brand,
                          label: 'Instagram',
                          onTap: () {
                            launchUrl(
                              Uri.parse('https://instagram.com/aadith.cv'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                        _buildSocialButton(
                          icon: FontAwesome.telegram_brand,
                          label: 'Telegram',
                          onTap: () {
                            launchUrl(
                              Uri.parse('https://t.me/artwebtech'),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Credits/Thanks Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Default_Theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Special Thanks',
                      style: TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCreditTile(
                      name: 'Rinshan',
                      role: 'Testing',
                      icon: MingCute.user_star_line,
                    ),
                    const SizedBox(height: 12),
                    _buildCreditTile(
                      name: 'Aswin',
                      role: 'Spotify API',
                      icon: FontAwesome.spotify_brand,
                    ),
                    const SizedBox(height: 12),
                    _buildCreditTile(
                      name: 'Jaganadh',
                      role: 'Testing',
                      icon: MingCute.user_star_line,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Support Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Default_Theme.spotifyGreen, Color(0xFF1ED760)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DonateSettings(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Support Development',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Footer
              Text(
                '© 2024 Aadith C V',
                style: TextStyle(
                  color: Default_Theme.primaryColor2.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Default_Theme.cardColorLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Default_Theme.primaryColor1, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditTile({
    required String name,
    required String role,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Default_Theme.spotifyGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Default_Theme.spotifyGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                role,
                style: TextStyle(
                  color: Default_Theme.primaryColor2.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
