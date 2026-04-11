import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

class PreferenceSelectionScreen extends StatefulWidget {
  const PreferenceSelectionScreen({super.key});

  @override
  State<PreferenceSelectionScreen> createState() => _PreferenceSelectionScreenState();
}

class _PreferenceSelectionScreenState extends State<PreferenceSelectionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Set<String> _selectedLanguages = {};
  final Set<String> _selectedArtists = {};

  final List<String> _languages = [
    'English', 'Hindi', 'Punjabi', 'Tamil', 'Telugu', 
    'Malayalam', 'Kannada', 'Bengali', 'Marathi', 'Bhojpuri'
  ];

  final List<Map<String, String>> _artists = [
    {'name': 'Arijit Singh', 'tag': 'Hindi', 'imageUrl': 'https://c.saavncdn.com/artist/Arijit_Singh_007_20230222181515_500x500.jpg'},
    {'name': 'Atif Aslam', 'tag': 'Hindi', 'imageUrl': 'https://c.saavncdn.com/artist/Atif_Aslam_500x500.jpg'},
    {'name': 'Vishal Mishra', 'tag': 'Hindi', 'imageUrl': 'https://c.saavncdn.com/artist/Vishal_Mishra_500x500.jpg'},
    {'name': 'Sid Sriram', 'tag': 'Tamil', 'imageUrl': 'https://c.saavncdn.com/artist/Sid_Sriram_500x500.jpg'},
    {'name': 'Anirudh Ravichander', 'tag': 'Tamil', 'imageUrl': 'https://c.saavncdn.com/artist/Anirudh_Ravichander_500x500.jpg'},
    {'name': 'Diljit Dosanjh', 'tag': 'Punjabi', 'imageUrl': 'https://c.saavncdn.com/artist/Diljit_Dosanjh_500x500.jpg'},
    {'name': 'Taylor Swift', 'tag': 'English', 'imageUrl': 'https://c.saavncdn.com/artist/Taylor_Swift_500x500.jpg'},
    {'name': 'Ed Sheeran', 'tag': 'English', 'imageUrl': 'https://c.saavncdn.com/artist/Ed_Sheeran_500x500.jpg'},
    {'name': 'Dua Lipa', 'tag': 'English', 'imageUrl': 'https://c.saavncdn.com/artist/Dua_Lipa_500x500.jpg'},
    {'name': 'Justin Bieber', 'tag': 'English', 'imageUrl': 'https://c.saavncdn.com/artist/Justin_Bieber_500x500.jpg'},
    {'name': 'Shreya Ghoshal', 'tag': 'Hindi', 'imageUrl': 'https://c.saavncdn.com/artist/Shreya_Ghoshal_500x500.jpg'},
    {'name': 'Badshah', 'tag': 'Hindi', 'imageUrl': 'https://c.saavncdn.com/artist/Badshah_500x500.jpg'},
    {'name': 'Drake', 'tag': 'English', 'imageUrl': 'https://c.saavncdn.com/artist/Drake_500x500.jpg'},
    {'name': 'Karthik', 'tag': 'Tamil', 'imageUrl': 'https://c.saavncdn.com/artist/Karthik_500x500.jpg'},
    {'name': 'Vijay Prakash', 'tag': 'Kannada', 'imageUrl': 'https://c.saavncdn.com/artist/Vijay_Prakash_500x500.jpg'},
  ];

  void _onNext() {
    if (_currentPage == 0) {
      if (_selectedLanguages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one language')),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Navigate immediately to ensure responsiveness
    if (mounted) {
      context.go('/Explore');
    }
    
    // Save to Firebase in the background
    try {
      CloudSyncService().saveUserPreferences(
        languages: _selectedLanguages.toList(),
        artists: _selectedArtists.toList(),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('PreferenceSelection: Background sync failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildLanguagePage(),
                  _buildArtistPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/icons/beats_music_logo.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) => const Icon(MingCute.music_2_fill, color: Default_Theme.successAccent),
          ),
          TextButton(
            onPressed: () => context.go('/Explore'),
            child: Text(
              'Skip',
              style: Default_Theme.secondoryTextStyle.copyWith(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What languages do\nyou listen to?',
            style: Default_Theme.primaryTextStyle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose up to 5 languages for better suggestions.',
            style: Default_Theme.secondoryTextStyle.copyWith(
              fontSize: 16,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _languages.map((lang) {
                final isSelected = _selectedLanguages.contains(lang);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedLanguages.remove(lang);
                      } else if (_selectedLanguages.length < 5) {
                        _selectedLanguages.add(lang);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Default_Theme.successAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? Default_Theme.successAccent : Default_Theme.primaryColor1.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      lang,
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Default_Theme.primaryColor1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Choose your favorite\nartists',
            style: Default_Theme.primaryTextStyle.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: _artists.length,
              itemBuilder: (context, index) {
                final artist = _artists[index];
                final name = artist['name']!;
                final isSelected = _selectedArtists.contains(name);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedArtists.remove(name);
                      } else {
                        _selectedArtists.add(name);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Default_Theme.primaryColor1.withValues(alpha: 0.1),
                              border: Border.all(
                                color: isSelected ? Default_Theme.successAccent : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: artist['imageUrl']!,
                                fit: BoxFit.cover,
                                color: isSelected ? Colors.black.withValues(alpha: 0.4) : null,
                                colorBlendMode: isSelected ? BlendMode.darken : null,
                                placeholder: (context, url) => Center(
                                  child: Icon(MingCute.user_2_fill, color: Default_Theme.primaryColor1.withValues(alpha: 0.2), size: 40),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0] : '?',
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Default_Theme.successAccent.withValues(alpha: 0.2),
                                ),
                                child: const Center(
                                  child: Icon(MingCute.check_fill, size: 32, color: Default_Theme.successAccent),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Default_Theme.successAccent : Default_Theme.primaryColor1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Default_Theme.successAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == 0 ? 'Next' : 'Finish',
                style: Default_Theme.secondoryTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
