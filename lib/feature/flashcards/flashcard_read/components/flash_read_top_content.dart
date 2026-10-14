import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashReadTopContent extends StatelessWidget {
  const FlashReadTopContent({
    super.key,
    required this.controller,
  });

  final FlashcardReadController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.currentIndex.value + 1;
      final total = controller.totalCards;
      final progress = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
        child: Column(
          children: [
            Row(
              children: [
                _TopBackButton(onTap: Get.back),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/judul-kartu.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    controller.flashcard.title ??
                                        'Judul Flashcard',
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      height: 1,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _ReadProgressBar(
                progress: progress,
                current: current,
                total: total,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _TopBackButton extends StatelessWidget {
  const _TopBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ReadProgressBar extends StatelessWidget {
  const _ReadProgressBar({
    required this.progress,
    required this.current,
    required this.total,
  });

  final double progress;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFD7C7EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2B2451),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1CE7A6),
                  borderRadius: BorderRadius.horizontal(
                    left: const Radius.circular(10),
                    right: progress >= 0.99
                        ? const Radius.circular(10)
                        : Radius.zero,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '$current/$total',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
