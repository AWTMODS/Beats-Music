import 'package:beats_music/theme_data/default.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        elevation: 0,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "Privacy Policy",
              "Last updated: December 14, 2025\n\n"
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
              "We use Your Personal Data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.",
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
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
