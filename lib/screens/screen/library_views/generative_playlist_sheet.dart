import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:beats_music/services/generative_ai_service.dart';
import 'package:beats_music/services/meta_resolver/cross_plugin_resolver.dart';
import 'package:beats_music/services/plugin/plugin_service.dart';
import 'package:beats_music/services/generative_playlist_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beats_music/core/di/service_locator.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

class GenerativePlaylistSheet extends StatefulWidget {
  final GenerativePlaylistManager manager;

  const GenerativePlaylistSheet({Key? key, required this.manager}) : super(key: key);

  @override
  State<GenerativePlaylistSheet> createState() => _GenerativePlaylistSheetState();

  static Future<void> show(BuildContext context) async {
    final aiService = GenerativeAiService();
    final pluginService = ServiceLocator.pluginService;
    final resolver = CrossPluginResolver(pluginService: pluginService);
    
    final manager = GenerativePlaylistManager(
      aiService: aiService,
      pluginService: pluginService,
      resolver: resolver,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) => GenerativePlaylistSheet(manager: manager),
    );
  }
}

class _GenerativePlaylistSheetState extends State<GenerativePlaylistSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  double _loadProgress = 0.0;
  double _trackCount = 20.0;
  
  bool _showApiKeyInput = false;
  final TextEditingController _apiKeyController = TextEditingController();
  late AnimationController _pulseController;

  final List<String> _suggestions = [
    "90s Malayalam Melodies",
    "Energetic Gym Motivation",
    "Late Night Lo-Fi Beats",
    "Tamil Romantic Hits",
    "Upbeat 80s Pop",
    "Relaxing Rainfall Piano",
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomApiKey();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _apiKeyController.text = prefs.getString('gen_ai_custom_api_key') ?? '';
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    await GenerativeAiService().setCustomApiKey(key);
    if (mounted) {
      SnackbarService.showMessage(key.isEmpty ? 'Custom API Key removed' : 'Custom API Key saved');
      setState(() {
        _showApiKeyInput = false;
      });
    }
  }

  Future<void> _generate() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      SnackbarService.showMessage('Please enter a prompt');
      return;
    }

    setState(() {
      _isLoading = true;
      _loadProgress = 0.0;
    });

    try {
      final playlistId = await widget.manager.createFromPrompt(
        prompt, 
        count: _trackCount.toInt(),
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _loadProgress = progress;
            });
          }
        },
      );
      if (mounted) {
        if (playlistId != null) {
          SnackbarService.showMessage('AI Playlist Generated Successfully!');
          context.pop();
        } else {
          SnackbarService.showMessage('Failed to generate playlist. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 15, 0, 19).withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: EdgeInsets.fromLTRB(25, 15, 25, 25 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                _buildMagicIcon(),
                const SizedBox(width: 15),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Magic Playlist",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSans',
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "Powered by Gemini AI",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _showApiKeyInput ? MingCute.close_line : MingCute.key_2_line,
                    color: Colors.white54,
                    size: 24,
                  ),
                  onPressed: () => setState(() => _showApiKeyInput = !_showApiKeyInput),
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (_showApiKeyInput) ...[
              TextField(
                controller: _apiKeyController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Enter your Gemini API key",
                  hintStyle: TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.white12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(MingCute.check_line, color: Default_Theme.primaryColor1),
                    onPressed: _saveApiKey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              "What are we listening to?",
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "e.g. Rain-themed acoustic songs...",
                hintStyle: TextStyle(color: Colors.white10),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestions.map((s) => _buildSuggestionChip(s)).toList(),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Tracks",
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  _trackCount.toInt().toString(),
                  style: const TextStyle(color: Default_Theme.primaryColor1, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Default_Theme.primaryColor1,
                inactiveTrackColor: Colors.white10,
                thumbColor: Colors.white,
                overlayColor: Default_Theme.primaryColor1.withOpacity(0.2),
                valueIndicatorColor: Default_Theme.primaryColor1,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: _trackCount,
                min: 10,
                max: 50,
                divisions: 4,
                label: _trackCount.toInt().toString(),
                onChanged: _isLoading ? null : (val) => setState(() => _trackCount = val),
              ),
            ),
            const SizedBox(height: 15),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMagicIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isLoading)
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: _loadProgress,
              strokeWidth: 3,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Default_Theme.primaryColor1),
            ),
          ),
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.1).animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Default_Theme.primaryColor1.withOpacity(0.2),
            ),
            child: Icon(
              _isLoading ? MingCute.loading_3_line : MingCute.magic_3_fill, 
              color: Default_Theme.primaryColor1, 
              size: 28
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
     return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isLoading 
              ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
              : const LinearGradient(
                  colors: [Default_Theme.primaryColor1, Color(0xFF00E676)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isLoading ? [] : [
              BoxShadow(
                color: Default_Theme.primaryColor1.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Generating...",
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "${(_loadProgress * 100).toInt()}%",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(MingCute.magic_3_line, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Generate",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ActionChip(
        label: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        backgroundColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        onPressed: _isLoading
            ? null
            : () {
                _controller.text = text;
              },
      ),
    );
  }
}
