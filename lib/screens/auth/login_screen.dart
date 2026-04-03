import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/auth_service.dart';
import 'package:beats_music/screens/widgets/privacy_policy_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:beats_music/core/constants/route_paths.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleGoogleSignIn() async {
    if (!_agreedToTerms) return;
    setState(() => _isLoading = true);

    try {
      final userCredential = await AuthService().signInWithGoogle();
      debugPrint(
          "LoginScreen: Google Sign-In result: ${userCredential?.user?.email}");
      if (userCredential != null) {
        // Reset skipped flag on successful login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('login_skipped', false);

        debugPrint("LoginScreen: Checking user preferences...");
        final preferences = await CloudSyncService().getUserPreferences();

        if (mounted) {
          if (preferences['languages']!.isEmpty) {
            debugPrint("LoginScreen: New user. Navigating to Preferences...");
            context.goNamed(RoutePaths.preferenceSelectionScreen);
          } else {
            debugPrint("LoginScreen: Returning user. Navigating to Home...");
            _navigateToHome();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sign in failed or cancelled")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestMode() async {
    if (!_agreedToTerms) return;
    setState(() => _isLoading = true);

    // Save skipped state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('login_skipped', true);

    await Future.delayed(
        const Duration(milliseconds: 500)); // Creating experience
    _navigateToHome();
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/Explore');
    }
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.themeColor,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor1.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Logo
                   Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(30),
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/beats_music_logo.png'),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    "Welcome to Beats",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    "Your personal cloud music player.\nSync your playlists and stats across devices.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  
                  const Spacer(),

                  // Terms and Conditions Checkbox
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            activeColor: AppTheme.successAccent,
                            checkColor: AppTheme.themeColor,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(text: "I agree to the "),
                                TextSpan(
                                  text: "Terms and Conditions",
                                  style: const TextStyle(
                                    color: AppTheme.successAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _showPrivacyPolicy,
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: const TextStyle(
                                    color: AppTheme.successAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _showPrivacyPolicy,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isLoading)
                    const CircularProgressIndicator(color: AppTheme.accentColor2)
                  else ...[
                    // Google Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _agreedToTerms ? _handleGoogleSignIn : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _agreedToTerms ? Colors.white : Colors.white24,
                          foregroundColor: _agreedToTerms ? Colors.black : Colors.white30,
                          elevation: _agreedToTerms ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(FontAwesome.google_brand),
                        label: const Text(
                          "Sign in with Google",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Guest Mode Button
                    TextButton(
                      onPressed: _agreedToTerms ? _handleGuestMode : null,
                      child: Text(
                        "Skip for now (Guest Mode)",
                        style: TextStyle(
                          color: _agreedToTerms ? Colors.white60 : Colors.white24,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
