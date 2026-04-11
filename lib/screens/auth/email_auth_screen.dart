import 'package:beats_music/core/constants/route_paths.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/services/auth_service.dart';
import 'package:beats_music/services/cloud_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Optimized list of common disposable email domains
  static const List<String> _tempDomains = [
    'mailinator.com', 'guerrillamail.com', '10minutemail.com', 'temp-mail.org',
    'yopmail.com', 'dispostable.com', 'sharklasers.com', 'getnada.com',
    'maildrop.cc', 'tempmail.com', 'throwawaymail.com', 'burnermail.io'
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    // Temp Mail Blocker
    final domain = value.split('@').last.toLowerCase();
    if (_tempDomains.contains(domain)) {
      return 'Temporary email addresses are not allowed';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await AuthService().signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await AuthService().registerWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('login_skipped', false);

      if (mounted) {
        final preferences = await CloudSyncService().getUserPreferences();
        if (preferences['languages']!.isEmpty) {
          context.goNamed(RoutePaths.preferenceSelectionScreen);
        } else {
          context.go('/Explore');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email first")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Save email for later retrieval during deep linking
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('magic_link_email', email);
      
      await AuthService().sendSignInLinkToEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Magic link sent to $email! Check your inbox.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Magic Link Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email to reset password")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset link sent to $email!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reset Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.themeColor,
      appBar: AppBar(
        title: Text(_isLogin ? "Login" : "Create Account", 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Email Address", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Enter your email", MingCute.mail_line),
              ),
              const SizedBox(height: 24),
              const Text("Password", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Enter password", MingCute.lock_line).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? MingCute.eye_close_line : MingCute.eye_line, color: Colors.white30),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: const Text("Forgot Password?", style: TextStyle(color: AppTheme.successAccent)),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? "Sign In" : "Sign Up", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleMagicLink,
                  icon: const Icon(MingCute.send_fill),
                  label: const Text("Send Magic Link (Passwordless)"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? "Don't have an account?" : "Already have an account?", 
                    style: const TextStyle(color: Colors.white54)),
                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(_isLogin ? "Sign Up" : "Login", 
                      style: const TextStyle(color: AppTheme.successAccent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      prefixIcon: Icon(icon, color: Colors.white30),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.successAccent, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
