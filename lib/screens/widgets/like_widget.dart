import 'package:beats_music/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:beats_music/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LikeBtnWidget extends StatefulWidget {
  bool isLiked;
  final bool isPlaying;
  final double iconSize;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  LikeBtnWidget({
    Key? key,
    this.isLiked = false,
    this.isPlaying = false,
    this.iconSize = 50,
    this.onLiked,
    this.onDisliked,
  }) : super(key: key);

  @override
  State<LikeBtnWidget> createState() => _LikeBtnWidgetState();
}

class _LikeBtnWidgetState extends State<LikeBtnWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    if (widget.isLiked) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final accentColor = state.dynamicAccentColor;
        final secondaryColor = HSLColor.fromColor(accentColor)
            .withSaturation((HSLColor.fromColor(accentColor).saturation * 0.7)
                .clamp(0.0, 1.0))
            .toColor();

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              widget.isLiked = !widget.isLiked;
              if (widget.isLiked) {
                _controller.forward(from: 0.0);
                widget.onLiked?.call();
              } else {
                _controller.reverse();
                widget.onDisliked?.call();
              }
            });
          },
          child: SizedBox(
            width: widget.iconSize + 10,
            height: widget.iconSize + 10,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Use Lottie for the "Like" animation
                Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_m6cu9m9f.json', // Heart pop animation
                  controller: _controller,
                  width: widget.iconSize * 2,
                  height: widget.iconSize * 2,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(
                        const ['**', 'Shape Layer 1', '**'],
                        value: widget.isPlaying ? accentColor : secondaryColor,
                      ),
                    ],
                  ),
                ),
                // Consistent heart fallback
                Opacity(
                  opacity: widget.isLiked ? (_controller.isAnimating ? 0 : 1) : 1,
                  child: Icon(
                    widget.isLiked ? AntDesign.heart_fill : AntDesign.heart_outline,
                    color: widget.isPlaying ? accentColor : secondaryColor,
                    size: widget.iconSize,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Icon heartIcon({bool isliked = false, Color? color, double size = 50}) {
  final displayColor = color ?? Default_Theme.accentColor2;
  return isliked
      ? Icon(
          AntDesign.heart_fill,
          color: displayColor,
          size: size,
        )
      : Icon(
          AntDesign.heart_outline,
          color: displayColor,
          size: size,
        );
}
