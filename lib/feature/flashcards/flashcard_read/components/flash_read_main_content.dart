import 'dart:math';

import 'package:epic_story_app/core/styles/epic_box_colors.dart';
import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/core/widgets/cards/box_shadow.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_card_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

import '../flashcard_read_controller.dart';

class FlashReadMainContent extends StatelessWidget {
  const FlashReadMainContent({
    super.key,
    required this.controller,
  });

  final FlashcardReadController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = EpicAppSize.screenWidth * 0.85;
          final cardHeight = constraints.maxHeight * 0.95;

          return Center(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                controller.updateDrag(details.delta.dx);
              },
              onHorizontalDragEnd: (_) {
                controller.endDrag();
              },
              child: Obx(() {
                final dragX = controller.dragOffset.value;
                final isQuizCard = controller.isQuiz;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: dragX),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  builder: (context, dx, child) {
                    final rotationZ = (dx / 320) * 0.18; // softer tilt
                    final lift = -(dx.abs() / 320) * 10; // softer lift

                    return AnimatedBuilder(
                      animation: controller.flipAnimation,
                      builder: (context, animatedChild) {
                        final flipValue = controller.flipAnimation.value;
                        final direction = controller.flipDirection.value;
                        final rawAngle = flipValue * pi * direction;
                        final isSecondHalf = flipValue > 0.5;
                        final correctedAngle = isSecondHalf
                            ? rawAngle - (pi * direction)
                            : rawAngle;

                        final flipCenter = (flipValue - 0.5).abs();
                        final scale = 0.96 +
                            (0.04 * (1 - flipCenter * 2).clamp(0.0, 1.0));

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0022)
                            ..translate(dx, lift)
                            ..rotateZ(rotationZ)
                            ..rotateY(correctedAngle)
                            ..scale(scale),
                          child: animatedChild,
                        );
                      },
                      child: child,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ShadowBox(
                        key: ValueKey(controller.currentIndex.value),
                        width: cardWidth,
                        height: cardHeight,
                        padding: const EdgeInsets.all(18),
                        cardColor: BoxColors.cardColorQuiz,
                        cardGradient: isQuizCard
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF118B99),
                                  Color(0xFF1CE7FF),
                                ],
                                stops: [0.1, 1.0],
                              ),
                        shadowGradient: isQuizCard
                            ? null
                            : const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF0D6874),
                                  Color(0xFF118B99),
                                ],
                              ),
                        radius: BorderRadius.circular(
                          EpicAppSize.calculatedSize(24),
                        ),
                        child: LayoutBuilder(
                          builder: (context, boxConstraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: boxConstraints.maxHeight,
                                ),
                                child: Center(
                                  child: Obx(() {
                                    if (controller.isLoading.value) {
                                      return const CircularProgressIndicator();
                                    }
                                    final image = controller.currentImage.value;
                                    final text = controller.currentText.value;
                                    final hStart =
                                        controller.highlightedStart.value;
                                    final hEnd =
                                        controller.highlightedEnd.value;
                                    const baseStyle = TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                    );

                                    InlineSpan _buildWordSpan(
                                      String word,
                                      int start,
                                      TextStyle style,
                                      int? hStart,
                                      int? hEnd,
                                    ) {
                                      final end = start + word.length;
                                      final hasHighlight = hStart != null &&
                                          hEnd != null &&
                                          !(end <= hStart || start >= hEnd);
                                      final wordStyle = hasHighlight
                                          ? style.copyWith(
                                              backgroundColor: Colors.yellow
                                                  .withOpacity(0.4),
                                            )
                                          : style;

                                      return TextSpan(
                                        text: word,
                                        style: wordStyle,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => controller
                                              .speakWordAt(start, end),
                                      );
                                    }

                                    List<InlineSpan> _buildSpans(
                                        String fullText) {
                                      final spans = <InlineSpan>[];
                                      int cursor = 0;
                                      final regex = RegExp(r'\s+');
                                      for (final match
                                          in regex.allMatches(fullText)) {
                                        final word = fullText.substring(
                                            cursor, match.start);
                                        if (word.isNotEmpty) {
                                          spans.add(_buildWordSpan(word, cursor,
                                              baseStyle, hStart, hEnd));
                                        }

                                        final space = fullText.substring(
                                            match.start, match.end);
                                        spans.add(TextSpan(
                                            text: space, style: baseStyle));
                                        cursor = match.end;
                                      }

                                      if (cursor < fullText.length) {
                                        final tail = fullText.substring(cursor);
                                        spans.add(_buildWordSpan(tail, cursor,
                                            baseStyle, hStart, hEnd));
                                      }
                                      return spans;
                                    }

                                    if (controller.isQuiz) {
                                      return controller.getQuizWidget();
                                    }
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Visibility(
                                          visible:
                                              image != null && image.isNotEmpty,
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                  image ?? '',
                                                  width: cardWidth * 0.9,
                                                  height: cardHeight * 0.4,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: cardWidth * 0.9,
                                                      height: cardHeight * 0.4,
                                                      color: Colors.black12,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 48,
                                                        color: Colors.black45,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: _buildSpans(text),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: -20,
                        right: 16,
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const SizedBox();
                          }
                          final isCorrect =
                              controller.quizController.isAnswerCorrect.value;
                          String? explanation;
                          if (!controller.isQuiz) {
                            return const SizedBox();
                          }
                          FlashcardCardEntity? currentCard =
                              controller.currentCard.value;
                          final quizType = currentCard?.quizType;
                          if (quizType == 1) {
                            explanation =
                                currentCard?.quiz?.multipleChoice?.explanation;
                          } else if (quizType == 2) {
                            explanation =
                                currentCard?.quiz?.fillBlank?.explanation;
                          } else if (quizType == 3) {
                            explanation = currentCard?.quiz?.group?.explanation;
                          }

                          if (isCorrect) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => controller.quizController
                                    .showExplanationDialog(explanation),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (isCorrect) {
                            return const SizedBox();
                          }
                          final retries = controller.retryQuestion.value;

                          if (retries <= 0) {
                            return Row(
                              children: [
                                _PulsingRetryButton(
                                  onPressed: () {
                                    controller.generateQuiz(
                                      forceGenerate: true,
                                    );
                                  },
                                ),
                                SizedBox(width: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => controller.quizController
                                        .showExplanationDialog(explanation),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.help_outline,
                                        size: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: BoxColors.purplePrimary.backgroundColor,
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (index) {
                                final filled = retries > index;
                                return Padding(
                                  padding:
                                      EdgeInsets.only(left: index == 0 ? 0 : 8),
                                  child: Icon(
                                    filled
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 30,
                                    color: filled
                                        ? Colors.pink
                                        : BoxColors.purplePrimary.textColor,
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}

class _PulsingRetryButton extends StatefulWidget {
  const _PulsingRetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PulsingRetryButton> createState() => _PulsingRetryButtonState();
}

class _PulsingRetryButtonState extends State<_PulsingRetryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF0DFF00),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(
            color: Colors.black,
            width: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: widget.onPressed,
        child: const Text(
          'Coba Lagi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
