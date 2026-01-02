import 'package:beats_music/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final bool isPlaying;
  const PlayPauseButton({
    Key? key,
    this.size = 60,
    this.onPlay,
    this.onPause,
    this.isPlaying = false,
  }) : super(key: key);
  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late bool _isPlaying;
  late Color _currentColor;
  void _togglePlayPause() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying ? widget.onPause!() : widget.onPlay!();
      _isPlaying = !_isPlaying;
      _currentColor =
          _isPlaying ? Default_Theme.accentColor1 : Default_Theme.accentColor2;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _size = widget.size;
    _isPlaying = widget.isPlaying;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final accentColor = state.dynamicAccentColor;
        // Generate a secondary color by shifting hue slightly or adjusting saturation for the "pause" state
        final secondaryColor = HSLColor.fromColor(accentColor)
            .withSaturation((HSLColor.fromColor(accentColor).saturation * 0.8).clamp(0.0, 1.0))
            .withLightness((HSLColor.fromColor(accentColor).lightness * 1.1).clamp(0.0, 1.0))
            .toColor();

        _currentColor = _isPlaying ? accentColor : secondaryColor;

        return GestureDetector(
          onTap: _togglePlayPause,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: _isPlaying ? 1.0 : 0.95),
            duration: const Duration(milliseconds: 100),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: _currentColor.withOpacity(0.4),
                          spreadRadius: 1,
                          blurRadius: 20)
                    ],
                    shape: BoxShape.circle,
                    color: _currentColor,
                  ),
                  width: _size,
                  height: _size,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: _isPlaying
                        ? Icon(
                            FontAwesome.pause_solid,
                            key: const ValueKey('pause'),
                            size: widget.size * 0.4,
                            color: Default_Theme.primaryColor1,
                          )
                        : Icon(
                            MingCute.play_fill,
                            key: const ValueKey('play'),
                            size: widget.size * 0.45,
                            color: Default_Theme.primaryColor1,
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
