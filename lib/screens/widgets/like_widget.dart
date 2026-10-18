import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:beats_music/core/theme/app_theme.dart';

class LikeBtnWidget extends StatefulWidget {
  final bool isLiked;
  final bool isPlaying;
  final double iconSize;
  final bool useSpotifyStyle;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  const LikeBtnWidget({
    Key? key,
    this.isLiked = false,
    this.isPlaying = false,
    this.iconSize = 50,
    this.useSpotifyStyle = false,
    this.onLiked,
    this.onDisliked,
  }) : super(key: key);

  @override
  State<LikeBtnWidget> createState() => _LikeBtnWidgetState();
}

class _LikeBtnWidgetState extends State<LikeBtnWidget> {
  @override
  Widget build(BuildContext context) {
    final iconData = widget.useSpotifyStyle
        ? (widget.isLiked ? MingCute.check_circle_fill : MingCute.add_circle_line)
        : (widget.isLiked ? AntDesign.heart_fill : AntDesign.heart_outline);
    final iconColor = widget.useSpotifyStyle
        ? (widget.isLiked ? AppTheme.successAccent : Colors.white70)
        : (widget.isLiked ? Colors.redAccent : Colors.white);

    return IconButton(
      onPressed: () {
        if (widget.isLiked) {
          widget.onDisliked?.call();
        } else {
          widget.onLiked?.call();
        }
      },
      icon: Icon(
        iconData,
        color: iconColor,
        size: widget.iconSize,
      ),
    );
  }
}


