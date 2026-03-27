import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SquareImgCard extends StatefulWidget {
  final String imgPath;
  final String? fallbackImgPath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final String? tag;
  final bool isWide;
  final bool isList;

  const SquareImgCard({
    super.key,
    required this.imgPath,
    this.fallbackImgPath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isWide = false,
    this.tag,
    this.isList = true,
  });

  @override
  State<SquareImgCard> createState() => _SquareImgCardState();
}

class _SquareImgCardState extends State<SquareImgCard> {
  bool _pressed = false;

  bool get _isInteractive => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_isInteractive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _onTapDown(TapDownDetails _) => _setPressed(true);
  void _onTapUp(TapUpDetails _) => _setPressed(false);
  void _onTapCancel() => _setPressed(false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: _isInteractive ? _onTapDown : null,
        onTapUp: _isInteractive ? _onTapUp : null,
        onTapCancel: _isInteractive ? _onTapCancel : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _pressed ? 0.85 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: SizedBox(
              width: widget.isWide ? 250 : 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(children: [
                      SizedBox(
                        height: 150,
                        width: widget.isWide ? 250 : 150,
                        child: LoadImageCached(
                          imageUrl: widget.imgPath,
                          fallbackUrl: widget.fallbackImgPath,
                        ),
                      ),
                      Visibility(
                        visible: widget.tag != null,
                        child: Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Default_Theme.accentColor2
                                  .withValues(alpha: 0.95),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                            child: widget.isList
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          MingCute.playlist_2_line,
                                          size: 18,
                                          color: Default_Theme.primaryColor2,
                                        ),
                                      ),
                                      Text(
                                        "${widget.tag}",
                                        style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Default_Theme.primaryColor2)
                                            .merge(Default_Theme
                                                .secondoryTextStyle),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Icon(
                                          MingCute.eye_2_line,
                                          size: 18,
                                          color: Default_Theme.primaryColor2,
                                        ),
                                      ),
                                      Text(
                                        "${widget.tag}",
                                        style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    Default_Theme.primaryColor2)
                                            .merge(Default_Theme
                                                .secondoryTextStyle),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                      if (widget.isWide)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Default_Theme.successAccent
                                      .withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
                  ),
                  if (!widget.isWide) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 32,
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Default_Theme.secondoryTextStyle.merge(
                            const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Default_Theme.primaryColor1,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style:
                              Default_Theme.secondoryTextStyle.merge(TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.62),
                            height: 1.1,
                          )),
                        ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


