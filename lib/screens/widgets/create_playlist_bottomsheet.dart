import 'dart:ui';

import 'package:beats_music/blocs/library/cubit/library_items_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:beats_music/core/theme/app_theme.dart';
import 'package:beats_music/l10n/app_localizations.dart';

void createPlaylistBottomSheet(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  final focusNode = FocusNode();

  showMaterialModalBottomSheet(
    context: context,
    expand: false,
    useRootNavigator: true,
    animationCurve: Curves.easeInOutBack,
    duration: const Duration(milliseconds: 500),
    elevation: 30,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.themeColor.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          l10n.playlistCreateNew,
                          style: AppTheme.secondoryTextStyleMedium.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Give your collection a name",
                          style: AppTheme.secondoryTextStyle.copyWith(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // TextField
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          textAlign: TextAlign.left,
                          style: AppTheme.secondoryTextStyleMedium.copyWith(
                            fontSize: 24,
                            color: AppTheme.successAccent,
                          ),
                          cursorColor: AppTheme.successAccent,
                          decoration: InputDecoration(
                            hintText: l10n.createPlaylistDialogNameHint,
                            hintStyle: AppTheme.secondoryTextStyleMedium.copyWith(
                              fontSize: 24,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (value) {
                            if (value.trim().length > 2) {
                              context
                                  .read<LibraryItemsCubit>()
                                  .createPlaylist(value.trim());
                              context.pop();
                            }
                          },
                        ),
                        const SizedBox(height: 40),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => context.pop(),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  l10n.buttonCancel,
                                  style: AppTheme.secondoryTextStyleMedium.copyWith(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ValueListenableBuilder<TextEditingValue>(
                                valueListenable: controller,
                                builder: (context, value, child) {
                                  final bool canCreate = value.text.trim().length > 2;
                                  return ElevatedButton(
                                    onPressed: canCreate
                                        ? () {
                                            context
                                                .read<LibraryItemsCubit>()
                                                .createPlaylist(value.text.trim());
                                            context.pop();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successAccent,
                                      foregroundColor: AppTheme.themeColor,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      disabledBackgroundColor: AppTheme.successAccent.withOpacity(0.2),
                                    ),
                                    child: Text(
                                      l10n.createPlaylistDialogCreate,
                                      style: AppTheme.secondoryTextStyleMedium.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}


