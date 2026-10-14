import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dialog_add_flashcard_coll.dart';

class FlashReadBottomContent extends StatelessWidget {
  const FlashReadBottomContent({
    super.key,
    required this.controller,
  });

  final FlashcardReadController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: [
              _navArrowButton(
                onTap: controller.goPrev,
                enabled: !controller.isFlipping.value &&
                    controller.currentIndex.value > 0,
                isPrevious: true,
              ),
              const SizedBox(width: 12),
              _navArrowButton(
                onTap: controller.goNext,
                enabled: !controller.isFlipping.value,
                isPrevious: false,
              ),
              const Spacer(),
              Row(
                children: [
                  _actionButton(
                    icon: controller.isSoundOn.value
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    onTap: controller.toggleSound,
                    enabled: !controller.isFlipping.value,
                    backgroundColor: const Color(0xFF999999),
                    iconColor: controller.isSoundOn.value
                        ? const Color(0xFFF3D86A)
                        : const Color(0xFFE4E4E4),
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    icon: controller.isBookmarked.value
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    onTap: () {
                      showAddFlashcardCollectionSheet(
                        context,
                        controller,
                        controller.flashcard,
                      );
                    },
                    enabled: true,
                    backgroundColor: const Color(0xFFFFED8C),
                    iconColor: const Color(0xFF8D8D8D),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navArrowButton({
    required VoidCallback onTap,
    required bool enabled,
    required bool isPrevious,
  }) {
    return _actionButton(
      icon: Icons.play_arrow_rounded,
      onTap: onTap,
      enabled: enabled,
      backgroundColor: const Color(0xFF66B0FF),
      iconColor: const Color(0xFF151515),
      isPrevious: isPrevious,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required Color backgroundColor,
    required Color iconColor,
    bool isPrevious = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2A2A2A),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateZ(isPrevious ? 3.14159 : 0),
              child: Icon(
                icon,
                size: 36,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
