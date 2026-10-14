import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:epic_story_app/core/styles/epic_box_colors.dart';
import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/core/widgets/cards/box_shadow.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/flash_read_bottom_content.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/flash_read_main_content.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/flash_read_top_content.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashCardReadPage extends GetView<FlashcardReadController> {
  const FlashCardReadPage({super.key});

  @override
  Widget build(BuildContext context) {
    EpicAppSize.initialize(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE0CEFF),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                FlashReadTopContent(
                  controller: controller,
                ),
                FlashReadMainContent(
                  controller: controller,
                ),
                FlashReadBottomContent(
                  controller: controller,
                ),
              ],
            ),
            // Confetti overlay aligned from bottom center shooting upward
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConfettiWidget(
                    confettiController:
                        controller.quizController.confettiController,
                    blastDirection: -math.pi / 2,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 28,
                    gravity: 0.25,
                    minBlastForce: 12,
                    maxBlastForce: 18,
                    colors: const [
                      Color(0xFF6B42B8),
                      Color(0xFF2ECC71),
                      Color(0xFFF39C12),
                      Color(0xFFE74C3C),
                      Color(0xFF3498DB),
                    ],
                    minimumSize: const Size(6, 8),
                    maximumSize: const Size(12, 18),
                    shouldLoop: false,
                  ),
                ),
              ),
            ),
            Obx(
              () {
                var isAnswerAlreadyCorrect =
                    controller.quizController.isAnswerCorrect.value;

                var isCanAnswer = (controller.retryQuestion.value > 0) &&
                    isAnswerAlreadyCorrect == false;
                var bgColor = isCanAnswer
                    ? BoxColors.cekJawaban
                    : isAnswerAlreadyCorrect
                        ? BoxColors.jawabanBenar
                        : BoxColors.jawabanSalah;
                return controller.isQuiz
                    ? Positioned(
                        bottom: EpicAppSize.calculatedSize(
                          105,
                        ),
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ShadowBox(
                            cardColor: bgColor,
                            isCanClick: isCanAnswer,
                            onTap: controller.quizController.onCheckAnswer,
                            width: MediaQuery.of(context).size.width * 0.65,
                            height: EpicAppSize.calculatedSize(50),
                            borderWidthRatio: EpicAppSize.borderWidthRatio,
                            radius: BorderRadius.circular(
                              EpicAppSize.calculatedSize(50),
                            ),
                            child: Center(
                              child: Text(
                                isAnswerAlreadyCorrect
                                    ? 'Jawaban sudah benar!'
                                    : 'Cek Jawaban',
                                style: TextStyle(
                                  color: bgColor.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
