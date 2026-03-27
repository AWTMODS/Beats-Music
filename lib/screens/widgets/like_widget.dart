import 'package:flutter/material.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class LikeBtnWidget extends StatefulWidget {
  final bool isLiked;
  final bool isPlaying;
  final double iconSize;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  const LikeBtnWidget({
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
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (widget.isLiked) {
          widget.onDisliked?.call();
        } else {
          widget.onLiked?.call();
        }
      },
      icon: Icon(
        widget.isLiked ? AntDesign.heart_fill : AntDesign.heart_outline,
        color: widget.isLiked ? Colors.redAccent : Colors.white,
        size: widget.iconSize,
      ),
    );
  }
}


