import 'package:epic_story_app/domain/entities/quiz/quiz_choice_entity.dart';
import 'package:epic_story_app/feature/books/presentation/book_quiz/book_quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookMultipleChoiceQuiz extends StatelessWidget {
  const BookMultipleChoiceQuiz({
    super.key,
    required this.quizController,
    required this.quizData,
  });

  final BookQuizController quizController;
  final QuizChoiceEntity quizData;

  @override
  Widget build(BuildContext context) {
    final choices = quizData.choices ?? [];
    final correctIndex = quizData.correctedIndex ?? -1;
    var image = quizData.image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (image != null)
          Column(
            children: [
              Image.network(
                image,
                width: 200,
                height: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
            ],
          ),
        Text(
          quizData.question ?? '-',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(choices.length, (index) {
          final label = String.fromCharCode(65 + index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Obx(() {
              final isSelected = quizController.assignedChoice.value == index;
              final isChecked = quizController.isAnswerChecked.value;
              final retryLeft = quizController.retryQuestion.value;
              final isCorrect = index == correctIndex;
              final showCorrect = quizController.isAnswerCorrect.value
                  ? (isChecked && isCorrect)
                  : (isChecked && isCorrect && retryLeft == 0);
              final showWrong = isChecked && isSelected && !isCorrect;
              final isLocked =
                  quizController.isAnswerCorrect.value || retryLeft == 0;
              const borderColor = Color(0xFF000000);

              Color fillColor = const Color(0xFFE0CEFF);
              if (isSelected) {
                fillColor = const Color(0xFF80A6FF);
              }
              if (showCorrect) {
                fillColor = const Color(0xFF51F279);
              } else if (showWrong) {
                fillColor = const Color(0xFFFF0000);
              }

              final textColor =
                  showWrong ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
              final bubbleColor =
                  showWrong ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
              final bubbleTextColor =
                  showWrong ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

              return GestureDetector(
                onTap: isLocked
                    ? null
                    : () {
                        quizController.selectChoice(index);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor,
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF3B1D73),
                        blurRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF000000),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: bubbleTextColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          choices[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
