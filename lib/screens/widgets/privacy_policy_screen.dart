import 'package:flutter/material.dart';
import 'package:beats_music/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Privacy Policy",
              "Last updated: April 3, 2026\n\n"
              "This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.",
            ),
            _buildSection(
              "Interpretation and Definitions",
              "The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.",
            ),
            _buildSection(
              "Collecting and Using Your Personal Data",
              "Types of Data Collected:\n\n"
              "• Personal Data: While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You.\n"
              "• Usage Data: Usage Data is collected automatically when using the Service.\n\n"
              "Data Protection & Portability:\n"
              "We take your privacy seriously. To ensure your data remains secure, all locally cached music data and preferences are automatically purged from your device upon signing out. This ensures that no sensitive playback history remains on the device once your session ends.",
            ),
            _buildSection(
              "YouTube Data",
              "Our service interacts with YouTube services. By using our application, you also agree to be bound by the YouTube Terms of Service.",
            ),
            _buildSection(
              "Contact Us",
              "If you have any questions about this Privacy Policy, You can contact us:\n\n"
              "• By email: support@beatsmusic.app",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
