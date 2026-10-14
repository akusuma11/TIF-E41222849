import 'dart:convert';

import 'package:confetti/confetti.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/data/models/mappers/quiz/history/quiz_choice_answer_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/history/quiz_fill_blank_answer_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/history/quiz_group_answer_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_choice_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_group_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz_fill_blank_mapper.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/history/quiz_choice_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/history/quiz_fill_blank_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/history/quiz_group_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_choice_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_group_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_fill_blank_entity.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_read_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashcardQuizController extends GetxController {
  FlashcardQuizController({required this.flashcardReadController});

  final FlashcardReadController flashcardReadController;

  final navController = Get.find<EpicNavigationController>();
  final isAnswerChecked = false.obs;
  final isAnswerCorrect = false.obs;
  final assignedChoice = (-1).obs;
  final assignedGroupByOption = <String, String>{}.obs;
  final assignedBlankByOption = <String, String>{}.obs;
  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(milliseconds: 1500));
  final ConfettiController dialogConfettiController =
      ConfettiController(duration: const Duration(milliseconds: 2000));

  void syncCurrentQuiz() {
    EpicLog.debug("_syncCurrentQuiz - Syncing quiz state with current card");
    final currentCard = flashcardReadController.currentCard.value;
    if (currentCard == null) return;
    EpicLog.debug(
        "_syncCurrentQuiz - Current card page: ${currentCard.nPage}, isQuiz: ${currentCard.quizType != null}");
    if (flashcardReadController.isQuiz) {
      final history = flashcardReadController.flashcardHistory.value;
      if (history == null) return;
      EpicLog.debug(
          "_syncCurrentQuiz - Found flashcard history with ${history.cards?.length ?? 0} cards");

      final cardHistoryIndex =
          history.cards?.indexWhere((h) => h.nPage == currentCard.nPage);
      if (cardHistoryIndex == null || cardHistoryIndex < 0) return;
      EpicLog.debug(
          "_syncCurrentQuiz - Found matching card history at index: $cardHistoryIndex");

      final cardHistory = history.cards![cardHistoryIndex];
      final historyAnswer = cardHistory.historyAnswer;
      EpicLog.debug(
          "_syncCurrentQuiz - historyAnswer ${historyAnswer?.answer}");
      if (historyAnswer == null) return;
      EpicLog.debug(
          "_syncCurrentQuiz - Found history answer for current card - quizType: ${historyAnswer.quizType}, retry: ${historyAnswer.retry}");
      final quizType = currentCard.quizType ?? 0;
      if (quizType == 1) {
        assignedChoice.value =
            historyAnswer.multipleChoiceAnswer?.selectedAnswer ?? -1;
        isAnswerChecked.value = true;
        isAnswerCorrect.value = cardHistory.correctAnswer ?? false;
        EpicLog.debug(
            "_syncCurrentQuiz - Synced multiple choice answer: selected index ${assignedChoice.value}");
      } else if (quizType == 2) {
        assignedBlankByOption.clear();
        assignedBlankByOption
            .addAll(historyAnswer.fillBlankAnswer?.assignedBlankByOption ?? {});
        isAnswerChecked.value = true;
        isAnswerCorrect.value = cardHistory.correctAnswer ?? false;
        EpicLog.debug(
            "_syncCurrentQuiz - Synced fill blank answer: assigned blanks $assignedBlankByOption");
      } else if (quizType == 3) {
        assignedGroupByOption.clear();
        assignedGroupByOption
            .addAll(historyAnswer.groupAnswer?.assignedGroupByOption ?? {});
        isAnswerChecked.value = true;
        isAnswerCorrect.value = cardHistory.correctAnswer ?? false;
        EpicLog.debug(
            "_syncCurrentQuiz - Synced group quiz answer: assigned groups $assignedGroupByOption");
      }
    }
  }

  void selectChoice(int index) {
    assignedChoice.value = index;
    isAnswerChecked.value = false;
  }

  void resetState() {
    assignedChoice.value = -1;
    isAnswerChecked.value = false;
    isAnswerCorrect.value = false;
    assignedGroupByOption.clear();
    assignedBlankByOption.clear();
  }

  @override
  void onClose() {
    confettiController.dispose();
    dialogConfettiController.dispose();
    super.onClose();
  }

  void _showCongratsDialog({
    String title = "Selamat!",
    String message = "Jawaban kamu benar.",
    String? explanation,
  }) {
    dialogConfettiController.play();
    Get.dialog(
      Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: dialogConfettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.18,
              numberOfParticles: 90,
              gravity: 0.22,
              minBlastForce: 8,
              maxBlastForce: 16,
              minimumSize: const Size(6, 10),
              maximumSize: const Size(14, 20),
              shouldLoop: true,
              colors: const [
                Color(0xFF6B42B8),
                Color(0xFF2ECC71),
                Color(0xFFF39C12),
                Color(0xFFE74C3C),
                Color(0xFF3498DB),
              ],
            ),
          ),
          // Dialog
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Main card
                Container(
                  margin: const EdgeInsets.only(top: 44),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF7D0),
                        Color(0xFFFFE566),
                        Color(0xFFFFCF20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE8A800),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8A800).withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(22, 58, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4A148C),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('⭐', style: TextStyle(fontSize: 22)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4E342E),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Get.back();
                          showExplanationDialog(
                            explanation,
                            showNextButton: true,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B42B8),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lanjut',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('🚀', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Trophy badge
                Positioned(
                  top: 0,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE8A800),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE8A800).withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 46)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }

  void showExplanationDialog(
    String? explanation, {
    bool showNextButton = false,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Main card
            Container(
              margin: const EdgeInsets.only(top: 44),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF6B42B8),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B42B8).withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Purple gradient header
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6B42B8), Color(0xFF9C5FD4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                      child: const Row(
                        children: [
                          Text('💡', style: TextStyle(fontSize: 22)),
                          SizedBox(width: 10),
                          Text(
                            'Penjelasan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: SingleChildScrollView(
                              child: Text(
                                explanation ?? 'Penjelasan belum tersedia.',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF37474F),
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (showNextButton)
                            GestureDetector(
                              onTap: () {
                                Get.back();
                                flashcardReadController.goToResult();
                              },
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6B42B8),
                                      Color(0xFF9C5FD4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      offset: Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Selanjutnya',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '✨',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: const Color(0xFF6B42B8),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6B42B8)
                                          .withOpacity(0.3),
                                      offset: const Offset(0, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Tutup',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF6B42B8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Lightbulb badge
            Positioned(
              top: -10,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE566), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFF6B42B8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('💡', style: TextStyle(fontSize: 42)),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: !showNextButton,
      barrierColor: Colors.black.withOpacity(0.4),
    );
  }

  void assignOptionToGroup(
      {required String optionId, required String? groupId}) {
    // Enforce max 4 items per group (unless reassigning same option to same group)
    if (groupId != null && groupId.isNotEmpty) {
      final currentGroupId = assignedGroupByOption[optionId];
      final currentCount = countForGroup(groupId);
      final alreadyInTarget = currentGroupId == groupId;
      if (!alreadyInTarget && currentCount >= 4) {
        EpicSnackBar.showErrorSnackBar(
          "Group Full",
          "Each group can only hold 4 items.",
        );
        return;
      }
    }

    if (optionId.isEmpty) return;
    if (groupId == null || groupId.isEmpty) {
      assignedGroupByOption.remove(optionId);
    } else {
      assignedGroupByOption[optionId] = groupId;
    }
    // reset check state on change
    isAnswerChecked.value = false;
  }

  void assignOptionToBlank(
      {required String optionId, required String? blankId}) {
    if (optionId.isEmpty) return;
    if (blankId == null || blankId.isEmpty) {
      assignedBlankByOption.remove(optionId);
    } else {
      assignedBlankByOption[optionId] = blankId;
    }
    isAnswerChecked.value = false;
  }

  int countForGroup(String groupId) {
    var count = 0;
    assignedGroupByOption.forEach((_, value) {
      if (value == groupId) count++;
    });
    return count;
  }

  void cleanupAssignments(Set<String> validOptionIds) {
    assignedGroupByOption
        .removeWhere((key, _) => !validOptionIds.contains(key));
    assignedBlankByOption
        .removeWhere((key, _) => !validOptionIds.contains(key));
  }

  Future<void> updateHistoryAnswer({
    required int quizType,
    required bool isCorrect,
    String? question,
    String? answer,
    QuizChoiceAnswerEntity? multipleChoiceAnswer,
    QuizChoiceEntity? multipleChoiceQuestion,
    QuizGroupAnswerEntity? groupAnswer,
    QuizGroupEntity? groupQuestion,
    QuizFillBlankAnswerEntity? fillBlankAnswer,
    QuizFillBlankEntity? fillBlankQuestion,
  }) async {
    final currentCard = flashcardReadController.currentCard.value;
    if (currentCard == null) return;

    final history = flashcardReadController.flashcardHistory.value;
    if (history == null) return;

    final cardHistoryIndex =
        history.cards?.indexWhere((h) => h.nPage == currentCard.nPage);
    if (cardHistoryIndex == null || cardHistoryIndex < 0) return;

    final cardHistory = history.cards![cardHistoryIndex];
    var updatedAnswer = FlashcardHistoryAnswerEntity(
      quizType: quizType,
      retry: flashcardReadController.retryQuestion.value,
      question: question,
      answer: answer,
    );

    if (quizType == 1) {
      updatedAnswer = updatedAnswer.copyWith(
        multipleChoiceQuestion: multipleChoiceQuestion,
        multipleChoiceAnswer: multipleChoiceAnswer,
      );
    } else if (quizType == 2) {
      updatedAnswer = updatedAnswer.copyWith(
        fillBlankQuestion: fillBlankQuestion,
        fillBlankAnswer: fillBlankAnswer,
      );
    } else if (quizType == 3) {
      updatedAnswer = updatedAnswer.copyWith(
        groupQuestion: groupQuestion,
        groupAnswer: groupAnswer,
      );
    }

    final updatedCardHistory = cardHistory.copyWith(
      correctAnswer: isCorrect,
      completedQuiz:
          isCorrect || flashcardReadController.retryQuestion.value <= 0,
      historyAnswer: updatedAnswer,
    );
    EpicLog.debug(
        "updateHistoryAnswer - ${updatedAnswer.groupAnswer?.assignedGroupByOption} - isCorrect: $isCorrect, retry left: ${flashcardReadController.retryQuestion.value}");

    var updatedCards = [...?history.cards];
    updatedCards[cardHistoryIndex] = updatedCardHistory;

    var totalCard = history.totalCards ?? 0;
    var totalQuiz = history.totalQuiz ?? 0;
    var completedQuiz = history.completedQuiz ?? 0;
    if (isCorrect) {
      if (completedQuiz < totalQuiz) {
        completedQuiz += 1;
      }
    }

    completedQuiz = completedQuiz;
    var isAllQuizCompleted = (completedQuiz >= totalQuiz);
    var readPages = (history.cards?.length ?? 0) + 1;
    var isAllRead = readPages >= totalCard;
    var isFinished = isAllRead && isAllQuizCompleted;
    var updatedHistory = history.copyWith(
      cards: updatedCards,
      completedQuiz: completedQuiz,
      isFinished: isFinished,
    );
    await flashcardReadController.childrenUsecase.updateFlashcardHistory(
      flashcardHistory: updatedHistory,
    );
    flashcardReadController.flashcardHistory.value = updatedHistory;
  }

  void onCheckAnswer() {
    EpicLog.debug("Checking answer - step 1: validate state");
    if (!flashcardReadController.isQuiz) return;

    int retryCount = flashcardReadController.retryQuestion.value;
    if (retryCount <= 0) {
      EpicSnackBar.showErrorSnackBar(
        "No Attempts Left",
        "You have used all your attempts for this question.",
      );
      return;
    }

    final quizType = flashcardReadController.currentCard.value?.quizType ?? 0;
    final quizData = flashcardReadController.currentCard.value?.quiz;

    EpicLog.debug(
        "Checking answer - step 2: determine quiz type and validate answer");

    if (quizType == 1) {
      EpicLog.debug(
          "Checking answer - step 3: processing multiple choice quiz");
      var quizDataEntity = quizData?.multipleChoice;
      if (quizDataEntity == null) return;
      final correctIndex = quizDataEntity.correctedIndex;
      if (correctIndex == null) return;

      EpicLog.debug(
          "Checking answer - step 4: comparing selected index with correct index");
      isAnswerCorrect.value = assignedChoice.value == correctIndex;
      isAnswerChecked.value = true;

      flashcardReadController.retryQuestion.value--;
      var answerData = QuizChoiceAnswerEntity(
        selectedAnswer: assignedChoice.value,
      );
      var questionJson =
          QuizChoiceMapper.entityToRemote(quizDataEntity).toJson();
      var answerJson =
          QuizChoiceAnswerMapper.entityToRemote(answerData).toJson();
      if (isAnswerCorrect.value) {
        _showCongratsDialog(
          title: "Selamat!",
          message: "Jawaban kamu benar.",
          explanation: quizDataEntity.explanation,
        );
        confettiController.play();
        updateHistoryAnswer(
          quizType: quizType,
          isCorrect: true,
          question: jsonEncode(questionJson),
          answer: jsonEncode(answerJson),
          multipleChoiceQuestion: quizDataEntity,
          multipleChoiceAnswer: answerData,
        );
      } else {
        EpicSnackBar.showErrorSnackBar(
          "Wrong Answer",
          "Please try again.",
        );
        updateHistoryAnswer(
          quizType: quizType,
          isCorrect: false,
          question: jsonEncode(questionJson),
          answer: jsonEncode(answerJson),
          multipleChoiceQuestion: quizDataEntity,
          multipleChoiceAnswer: answerData,
        );
      }
      return;
    }

    if (quizType == 3) {
      EpicLog.debug("Checking answer - step 3: processing group quiz");
      final QuizGroupEntity? quizDataEntity = quizData?.group;
      if (quizDataEntity == null) return;
      final options = quizDataEntity.options ?? [];
      if (options.isEmpty) return;

      EpicLog.debug("Checking answer - step 4: validating group assignments");

      bool allAssigned = true;
      bool allCorrect = true;

      for (final option in options) {
        final optId = option.id;
        final correctGroupId = option.correctGroupId;
        if (optId == null) {
          continue;
        }
        final assigned = assignedGroupByOption[optId];
        if (assigned == null) {
          allAssigned = false;
          allCorrect = false;
          continue;
        }
        if (correctGroupId != null && assigned != correctGroupId) {
          allCorrect = false;
        }
      }

      isAnswerChecked.value = true;
      isAnswerCorrect.value = allAssigned && allCorrect;

      flashcardReadController.retryQuestion.value--;
      final groupAssignments = Map<String, String>.from(assignedGroupByOption);
      var answerData = QuizGroupAnswerEntity(
        assignedGroupByOption: groupAssignments,
      );
      var questionJson =
          QuizGroupMapper.entityToRemote(quizDataEntity).toJson();
      var answerJson =
          QuizGroupAnswerMapper.entityToRemote(answerData).toJson();

      if (isAnswerCorrect.value) {
        _showCongratsDialog(
          title: "Selamat!",
          message: "Semua item sudah di kelompok yang benar.",
          explanation: quizDataEntity.explanation,
        );
        confettiController.play();
        updateHistoryAnswer(
          quizType: quizType,
          isCorrect: true,
          question: jsonEncode(questionJson),
          answer: jsonEncode(answerJson),
          groupQuestion: quizDataEntity,
          groupAnswer: answerData,
        );
      } else {
        final message = allAssigned
            ? "Some items are in the wrong group."
            : "Please assign all items to a group.";
        EpicSnackBar.showErrorSnackBar("Try Again", message);
        updateHistoryAnswer(
          quizType: quizType,
          isCorrect: false,
          question: jsonEncode(questionJson),
          answer: jsonEncode(answerJson),
          groupQuestion: quizDataEntity,
          groupAnswer: answerData,
        );
      }
      return;
    }

    if (quizType == 2) {
      EpicLog.debug("Checking answer - step 3: processing fill blank quiz");
      final QuizFillBlankEntity? quizDataEntity = quizData?.fillBlank;
      if (quizDataEntity == null) return;
      final options = quizDataEntity.options ?? [];
      if (options.isEmpty) return;

      bool allAssigned = true;
      bool allCorrect = true;

      for (final option in options) {
        final optId = option.id;
        final correctBlankId = option.correctBlankId;
        if (optId == null) continue;
        final assigned = assignedBlankByOption[optId];
        if (assigned == null) {
          allAssigned = false;
          allCorrect = false;
          continue;
        }
        if (correctBlankId != null && assigned != correctBlankId) {
          allCorrect = false;
        }
      }

      isAnswerChecked.value = true;
      isAnswerCorrect.value = allAssigned && allCorrect;

      flashcardReadController.retryQuestion.value--;
      final fillAssignments = Map<String, String>.from(assignedBlankByOption);
      var answerData = QuizFillBlankAnswerEntity(
        assignedBlankByOption: fillAssignments,
      );
      var questionJson =
          QuizFillBlankMapper.entityToRemote(quizDataEntity).toJson();
      var answerJson =
          QuizFillBlankAnswerMapper.entityToRemote(answerData).toJson();
      if (isAnswerCorrect.value) {
        _showCongratsDialog(
          title: "Selamat!",
          message: "Semua isian sudah benar.",
          explanation: quizDataEntity.explanation,
        );
        confettiController.play();
        updateHistoryAnswer(
          quizType: quizType,
          isCorrect: true,
          question: jsonEncode(questionJson),
          answer: jsonEncode(answerJson),
          fillBlankQuestion: quizDataEntity,
          fillBlankAnswer: answerData,
        );
      } else {
        final message = allAssigned
            ? "Some blanks are incorrect."
            : "Please fill all blanks.";
        EpicSnackBar.showErrorSnackBar("Try Again", message);
        updateHistoryAnswer(
          quizType: quizType,
          isCorrect: false,
          question: jsonEncode(questionJson),
          answer: jsonEncode(answerJson),
          fillBlankQuestion: quizDataEntity,
          fillBlankAnswer: answerData,
        );
      }
      return;
    }

    EpicSnackBar.showErrorSnackBar("Error", "Quiz type not supported");
  }
}
