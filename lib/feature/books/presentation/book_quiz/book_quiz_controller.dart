import 'dart:convert';

import 'package:epic_story_app/core/constants/quiz_prompt.dart';
import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/data/models/mappers/quiz/history/quiz_choice_answer_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/history/quiz_fill_blank_answer_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/history/quiz_group_answer_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_choice_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_fill_blank_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_group_mapper.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_choice_remote_model.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_fill_blank_remote_model.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_group_remote_model.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/domain/entities/book_history_quiz_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/history/quiz_choice_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/history/quiz_fill_blank_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/history/quiz_group_answer_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_choice_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_fill_blank_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_group_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/quiz_usecase.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BookQuizController extends GetxController {
  BookQuizController({
    required this.childrenUsecase,
    required this.quizUsecase,
  });

  final ChildrenUsecase childrenUsecase;
  final QuizUsecase quizUsecase;

  final navController = Get.find<EpicNavigationController>();
  final Rxn<BookHistoryEntity> bookHistory = Rxn<BookHistoryEntity>();
  final Rxn<BookEntity> currentBook = Rxn<BookEntity>();
  final RxBool isLoading = false.obs;

  final isAnswerChecked = false.obs;
  final isAnswerCorrect = false.obs;
  final retryQuestion = 3.obs;

  final assignedChoice = (-1).obs;
  final assignedGroupByOption = <String, String>{}.obs;
  final assignedBlankByOption = <String, String>{}.obs;
  String _theoryText = '';
  int? _bookQuizType;
  var title = ''.obs;

  BookHistoryQuizEntity? get quiz => bookHistory.value?.quiz;
  int get quizType => quiz?.quizType ?? 0;

  QuizChoiceEntity? get multipleChoiceQuiz => quiz?.multipleChoiceQuestion;
  QuizFillBlankEntity? get fillBlankQuiz => quiz?.fillBlankQuestion;
  QuizGroupEntity? get groupQuiz => quiz?.groupQuestion;

  bool get isQuizAvailable {
    final type = quizType;
    if (type == 1) return multipleChoiceQuiz != null;
    if (type == 2) return fillBlankQuiz != null;
    if (type == 3) return groupQuiz != null;
    return false;
  }

  String? get explanation {
    if (quiz?.explanation?.trim().isNotEmpty == true) {
      return quiz?.explanation;
    }
    if (quizType == 1) return multipleChoiceQuiz?.explanation;
    if (quizType == 2) return fillBlankQuiz?.explanation;
    if (quizType == 3) return groupQuiz?.explanation;
    return quiz?.explanation;
  }

  @override
  void onInit() {
    super.onInit();
    _initFromArguments();
  }

  void _initFromArguments() {
    final args = Get.arguments;
    BookHistoryEntity? history;

    if (args is BookHistoryEntity) {
      history = args;
    } else if (args is Map) {
      final rawHistory = args['history'];
      if (rawHistory is BookHistoryEntity) {
        history = rawHistory;
      }
      final theoryTextArg = args['theoryText'];
      if (theoryTextArg is String) {
        _theoryText = theoryTextArg;
      }
      final bookQuizTypeArg = args['bookQuizType'];
      if (bookQuizTypeArg is int) {
        _bookQuizType = bookQuizTypeArg;
      }
      final bookArg = args['book'];
      if (bookArg is BookEntity) {
        currentBook.value = bookArg;
      }
      title.value = history?.title ?? 'null';
    }

    if (history == null) {
      EpicLog.debug('BookQuizController - missing book history argument');
      return;
    }

    bookHistory.value = history;
    syncCurrentQuiz();
  }

  void syncCurrentQuiz() {
    final currentQuiz = quiz;
    retryQuestion.value = currentQuiz?.retry ?? 3;

    assignedChoice.value =
        currentQuiz?.multipleChoiceAnswer?.selectedAnswer ?? -1;

    assignedBlankByOption.clear();
    assignedBlankByOption
        .addAll(currentQuiz?.fillBlankAnswer?.assignedBlankByOption ?? {});

    assignedGroupByOption.clear();
    assignedGroupByOption
        .addAll(currentQuiz?.groupAnswer?.assignedGroupByOption ?? {});

    final hasStoredAnswer = (currentQuiz?.answer?.trim().isNotEmpty ?? false) ||
        currentQuiz?.multipleChoiceAnswer != null ||
        currentQuiz?.fillBlankAnswer != null ||
        currentQuiz?.groupAnswer != null;

    isAnswerChecked.value = hasStoredAnswer;
    isAnswerCorrect.value = _evaluateCurrentCorrectness();
  }

  bool _evaluateCurrentCorrectness() {
    final type = quizType;
    if (type == 1) {
      final q = multipleChoiceQuiz;
      if (q == null) return false;
      return q.correctedIndex == assignedChoice.value &&
          assignedChoice.value >= 0;
    }
    if (type == 2) {
      final q = fillBlankQuiz;
      if (q == null) return false;
      final options = q.options ?? const [];
      if (options.isEmpty) return false;
      for (final option in options) {
        final id = option.id;
        final correctBlank = option.correctBlankId;
        if (id == null || correctBlank == null) return false;
        final assigned = assignedBlankByOption[id];
        if (assigned != correctBlank) return false;
      }
      return true;
    }
    if (type == 3) {
      final q = groupQuiz;
      if (q == null) return false;
      final options = q.options ?? const [];
      if (options.isEmpty) return false;
      for (final option in options) {
        final id = option.id;
        final correctGroup = option.correctGroupId;
        if (id == null || correctGroup == null) return false;
        final assigned = assignedGroupByOption[id];
        if (assigned != correctGroup) return false;
      }
      return true;
    }
    return false;
  }

  void selectChoice(int index) {
    assignedChoice.value = index;
    isAnswerChecked.value = false;
  }

  void assignOptionToGroup(
      {required String optionId, required String? groupId}) {
    if (groupId != null && groupId.isNotEmpty) {
      final currentGroupId = assignedGroupByOption[optionId];
      final currentCount = countForGroup(groupId);
      final alreadyInTarget = currentGroupId == groupId;
      if (!alreadyInTarget && currentCount >= 4) {
        EpicSnackBar.showErrorSnackBar(
          'Group Full',
          'Setiap group maksimal 4 item.',
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
    String? explanation,
    QuizChoiceAnswerEntity? multipleChoiceAnswer,
    QuizChoiceEntity? multipleChoiceQuestion,
    QuizGroupAnswerEntity? groupAnswer,
    QuizGroupEntity? groupQuestion,
    QuizFillBlankAnswerEntity? fillBlankAnswer,
    QuizFillBlankEntity? fillBlankQuestion,
  }) async {
    final history = bookHistory.value;
    if (history == null) return;

    final existingQuiz = history.quiz;
    if (existingQuiz == null) return;

    final updatedQuiz = existingQuiz.copyWith(
      quizType: quizType,
      retry: retryQuestion.value,
      question: question ?? existingQuiz.question,
      answer: answer,
      explanation: explanation ?? existingQuiz.explanation,
      multipleChoiceQuestion:
          multipleChoiceQuestion ?? existingQuiz.multipleChoiceQuestion,
      multipleChoiceAnswer: multipleChoiceAnswer,
      fillBlankQuestion: fillBlankQuestion ?? existingQuiz.fillBlankQuestion,
      fillBlankAnswer: fillBlankAnswer,
      groupQuestion: groupQuestion ?? existingQuiz.groupQuestion,
      groupAnswer: groupAnswer,
    );

    final completed = [...?history.completedQuizes];
    if (isCorrect && !completed.contains(quizType)) {
      completed.add(quizType);
    }

    final finished = isCorrect;

    final updatedHistory = history.copyWith(
      quiz: updatedQuiz,
      completedQuizes: completed,
      lastReadAt: DateTime.now(),
      isFinished: finished,
      finishedAt: finished
          ? (history.finishedAt ?? DateTime.now())
          : history.finishedAt,
    );

    // Update local state first so UI/result stays consistent even if user leaves quickly.
    bookHistory.value = updatedHistory;
    await childrenUsecase.updateBookHistory(bookHistory: updatedHistory);
  }

  Future<void> onCheckAnswer() async {
    if (!isQuizAvailable) return;

    if (retryQuestion.value <= 0) {
      EpicSnackBar.showErrorSnackBar(
        'Kesempatan Habis',
        'Kesempatan menjawab untuk quiz ini sudah habis.',
      );
      return;
    }

    final type = quizType;
    if (type == 1) {
      final q = multipleChoiceQuiz;
      if (q == null) return;

      final correctIndex = q.correctedIndex;
      if (correctIndex == null || assignedChoice.value < 0) {
        EpicSnackBar.showWarningSnackBar(
            'Quiz', 'Pilih jawaban terlebih dahulu.');
        return;
      }

      isAnswerCorrect.value = assignedChoice.value == correctIndex;
      isAnswerChecked.value = true;
      retryQuestion.value--;

      final answerData = QuizChoiceAnswerEntity(
        selectedAnswer: assignedChoice.value,
      );
      final questionJson = QuizChoiceMapper.entityToRemote(q).toJson();
      final answerJson =
          QuizChoiceAnswerMapper.entityToRemote(answerData).toJson();

      if (isAnswerCorrect.value) {
        EpicSnackBar.showSuccessSnackBar('Benar', 'Jawaban kamu benar.');
      } else {
        EpicSnackBar.showErrorSnackBar('Salah', 'Coba lagi ya.');
      }

      await updateHistoryAnswer(
        quizType: type,
        isCorrect: isAnswerCorrect.value,
        question: jsonEncode(questionJson),
        answer: jsonEncode(answerJson),
        explanation: q.explanation,
        multipleChoiceQuestion: q,
        multipleChoiceAnswer: answerData,
      );
      // if (isAnswerCorrect.value) {
      //   navController.refreshRewardBook.value++;
      // }
      return;
    }

    if (type == 2) {
      final q = fillBlankQuiz;
      if (q == null) return;
      final options = q.options ?? const [];
      if (options.isEmpty) return;

      var allAssigned = true;
      var allCorrect = true;

      for (final option in options) {
        final id = option.id;
        final correctBlankId = option.correctBlankId;
        if (id == null) continue;
        final assigned = assignedBlankByOption[id];
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
      retryQuestion.value--;

      final answerData = QuizFillBlankAnswerEntity(
        assignedBlankByOption: Map<String, String>.from(assignedBlankByOption),
      );
      final questionJson = QuizFillBlankMapper.entityToRemote(q).toJson();
      final answerJson =
          QuizFillBlankAnswerMapper.entityToRemote(answerData).toJson();

      if (isAnswerCorrect.value) {
        EpicSnackBar.showSuccessSnackBar('Benar', 'Semua isian sudah benar.');
      } else {
        EpicSnackBar.showErrorSnackBar(
          'Salah',
          allAssigned
              ? 'Masih ada isian yang salah.'
              : 'Lengkapi semua isian dulu.',
        );
      }

      await updateHistoryAnswer(
        quizType: type,
        isCorrect: isAnswerCorrect.value,
        question: jsonEncode(questionJson),
        answer: jsonEncode(answerJson),
        explanation: q.explanation,
        fillBlankQuestion: q,
        fillBlankAnswer: answerData,
      );
      // if (isAnswerCorrect.value) {
      //   navController.refreshRewardBook.value++;
      // }
      return;
    }

    if (type == 3) {
      final q = groupQuiz;
      if (q == null) return;
      final options = q.options ?? const [];
      if (options.isEmpty) return;

      var allAssigned = true;
      var allCorrect = true;

      for (final option in options) {
        final id = option.id;
        final correctGroup = option.correctGroupId;
        if (id == null) continue;
        final assigned = assignedGroupByOption[id];
        if (assigned == null) {
          allAssigned = false;
          allCorrect = false;
          continue;
        }
        if (correctGroup != null && assigned != correctGroup) {
          allCorrect = false;
        }
      }

      isAnswerChecked.value = true;
      isAnswerCorrect.value = allAssigned && allCorrect;
      retryQuestion.value--;

      final answerData = QuizGroupAnswerEntity(
        assignedGroupByOption: Map<String, String>.from(assignedGroupByOption),
      );
      final questionJson = QuizGroupMapper.entityToRemote(q).toJson();
      final answerJson =
          QuizGroupAnswerMapper.entityToRemote(answerData).toJson();

      if (isAnswerCorrect.value) {
        EpicSnackBar.showSuccessSnackBar(
          'Benar',
          'Semua item sudah di kelompok yang tepat.',
        );
      } else {
        EpicSnackBar.showErrorSnackBar(
          'Salah',
          allAssigned
              ? 'Masih ada item di kelompok yang salah.'
              : 'Masukkan semua item ke group.',
        );
      }

      await updateHistoryAnswer(
        quizType: type,
        isCorrect: isAnswerCorrect.value,
        question: jsonEncode(questionJson),
        answer: jsonEncode(answerJson),
        explanation: q.explanation,
        groupQuestion: q,
        groupAnswer: answerData,
      );
      // if (isAnswerCorrect.value) {
      //   navController.refreshRewardBook.value++;
      // }
      return;
    }

    EpicLog.debug('BookQuizController - unsupported quiz type: $type');
  }

  void showExplanationDialog(String? explanationText) {
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
                                explanationText ?? 'Penjelasan belum tersedia.',
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
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
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
              top: 0,
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
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
    );
  }

  Future<void> forceGenerateQuiz() async {
    if (isLoading.value) return;

    final history = bookHistory.value;
    if (history == null) return;

    final text = _theoryText.trim();
    if (text.isEmpty) {
      EpicSnackBar.showErrorSnackBar(
        'Quiz',
        'Materi buku kosong, quiz tidak bisa digenerate ulang.',
      );
      return;
    }

    final type = _bookQuizType ?? quizType;
    if (type < 1 || type > 3) {
      EpicSnackBar.showErrorSnackBar(
        'Quiz',
        'Tipe quiz tidak valid untuk generate ulang.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final previousQuestions = _extractPreviousQuestions(history.quiz);
      final generatedQuiz = await _tryGenerateQuizByQuizType(
        quizType: type,
        text: text,
        category: currentBook.value?.category,
        previousQuestions: previousQuestions,
      );
      if (generatedQuiz == null) {
        EpicSnackBar.showErrorSnackBar(
          'Quiz',
          'Gagal generate ulang quiz.',
        );
        return;
      }

      final updatedHistory = history.copyWith(
        quiz: generatedQuiz,
        lastReadAt: DateTime.now(),
      );
      await childrenUsecase.updateBookHistory(bookHistory: updatedHistory);
      bookHistory.value = updatedHistory;
      syncCurrentQuiz();

      EpicSnackBar.showSuccessSnackBar(
        'Success',
        'Quiz berhasil digenerate ulang.',
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'forceGenerateQuiz');
      EpicSnackBar.showErrorSnackBar(
        'Quiz',
        'Terjadi kesalahan saat generate ulang quiz.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String> _extractPreviousQuestions(BookHistoryQuizEntity? quiz) {
    if (quiz == null) return [];
    final List<String> previous = [];
    if (quiz.multipleChoiceQuestion?.question != null) {
      previous.add(quiz.multipleChoiceQuestion!.question!);
    }
    if (quiz.fillBlankQuestion?.sentence != null) {
      final sentenceText = quiz.fillBlankQuestion!.sentence!
          .map((s) => s.type == 'blank' ? '___' : (s.value ?? ''))
          .join();
      if (sentenceText.trim().isNotEmpty) previous.add(sentenceText);
    }
    if (quiz.groupQuestion?.groups != null) {
      final groupTitles = quiz.groupQuestion!.groups!
          .map((g) => g.title ?? '')
          .where((t) => t.isNotEmpty)
          .join(' vs ');
      if (groupTitles.isNotEmpty) previous.add('Kelompokkan: $groupTitles');
    }
    return previous;
  }

  Future<BookHistoryQuizEntity?> _tryGenerateQuizByQuizType({
    required int quizType,
    required String text,
    String? category,
    List<String> previousQuestions = const [],
  }) async {
    try {
      if (quizType == 1) {
        final choiceQuiz = await _tryToGenerateMultipleChoiceQuiz(
          fullText: text,
          category: category,
          previousQuestions: previousQuestions,
        );
        if (choiceQuiz != null) {
          final remote = QuizChoiceMapper.entityToRemote(choiceQuiz);
          return BookHistoryQuizEntity(
            quizType: 1,
            retry: 3,
            question: jsonEncode(remote.toJson()),
            answer: null,
            explanation: choiceQuiz.explanation,
            multipleChoiceQuestion: choiceQuiz,
            multipleChoiceAnswer: null,
            fillBlankQuestion: null,
            fillBlankAnswer: null,
            groupQuestion: null,
            groupAnswer: null,
          );
        }
      } else if (quizType == 2) {
        final fillBlankQuiz = await _tryToGenerateFillBlankQuiz(
          fullText: text,
          category: category,
          previousQuestions: previousQuestions,
        );
        if (fillBlankQuiz != null) {
          final remote = QuizFillBlankMapper.entityToRemote(fillBlankQuiz);
          return BookHistoryQuizEntity(
            quizType: 2,
            retry: 3,
            question: jsonEncode(remote.toJson()),
            answer: null,
            explanation: fillBlankQuiz.explanation,
            multipleChoiceQuestion: null,
            multipleChoiceAnswer: null,
            fillBlankQuestion: fillBlankQuiz,
            fillBlankAnswer: null,
            groupQuestion: null,
            groupAnswer: null,
          );
        }
      } else if (quizType == 3) {
        final groupQuiz = await _tryToGenerateGroupQuiz(
          fullText: text,
          category: category,
          previousQuestions: previousQuestions,
        );
        if (groupQuiz != null) {
          final remote = QuizGroupMapper.entityToRemote(groupQuiz);
          return BookHistoryQuizEntity(
            quizType: 3,
            retry: 3,
            question: jsonEncode(remote.toJson()),
            answer: null,
            explanation: groupQuiz.explanation,
            multipleChoiceQuestion: null,
            multipleChoiceAnswer: null,
            fillBlankQuestion: null,
            fillBlankAnswer: null,
            groupQuestion: groupQuiz,
            groupAnswer: null,
          );
        }
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryGenerateQuizByQuizType');
    }
    return null;
  }

  Future<QuizChoiceEntity?> _tryToGenerateMultipleChoiceQuiz({
    required String fullText,
    String? category,
    List<String> previousQuestions = const [],
  }) async {
    try {
      final quizJson = await quizUsecase.generate(
        prompt: QuizPrompt.multipleChoicePrompt(
          text: fullText,
          category: category,
          previousQuestions: previousQuestions,
        ),
      );
      if (quizJson == null) return null;

      final parsed = jsonDecode(quizJson) as Map<String, dynamic>;
      final quizModel = QuizChoiceRemoteModel.fromJson(parsed);
      // === VALIDASI ===
      if (quizModel.question == null ||
          quizModel.choices == null ||
          quizModel.choices!.length != 4 ||
          quizModel.correctedIndex == null ||
          quizModel.correctedIndex! < 0 ||
          quizModel.correctedIndex! >= quizModel.choices!.length) {
        EpicLog.debug(
            '_tryToGenerateMultipleChoiceQuiz - invalid quiz structure');
        return null;
      }
      final quizEntity = QuizChoiceMapper.remoteToEntity(quizModel);
      return quizEntity.copyWith(
        quizDataHelper: quizModel.toJson().toString(),
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryToGenerateMultipleChoiceQuiz');
    }
    return null;
  }

  Future<QuizFillBlankEntity?> _tryToGenerateFillBlankQuiz({
    required String fullText,
    String? category,
    List<String> previousQuestions = const [],
  }) async {
    try {
      final quizJson = await quizUsecase.generate(
        prompt: QuizPrompt.fillBlankPrompt(
          text: fullText,
          category: category,
          previousQuestions: previousQuestions,
        ),
      );
      if (quizJson == null) return null;

      final parsed = jsonDecode(quizJson) as Map<String, dynamic>;
      final quizModel = QuizFillBlankRemoteModel.fromJson(parsed);
      // Validasi fill blank:
      if (quizModel.sentence == null ||
          quizModel.options == null ||
          quizModel.options!.length != 4 ||
          quizModel.sentence!.where((s) => s.type == 'blank').length != 4 ||
          quizModel.options!
              .any((o) => o.value == null || o.correctBlankId == null)) {
        EpicLog.debug('_tryToGenerateFillBlankQuiz - invalid quiz structure');
        return null;
      }
      final quizEntity = QuizFillBlankMapper.remoteToEntity(quizModel);
      return quizEntity.copyWith(
        quizDataHelper: quizModel.toJson().toString(),
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryToGenerateFillBlankQuiz');
    }
    return null;
  }

  Future<QuizGroupEntity?> _tryToGenerateGroupQuiz({
    required String fullText,
    String? category,
    List<String> previousQuestions = const [],
  }) async {
    try {
      final quizJson = await quizUsecase.generate(
        prompt: QuizPrompt.groupQuizPrompt(
          text: fullText,
          category: category,
          previousQuestions: previousQuestions,
        ),
      );
      if (quizJson == null) return null;

      final parsed = jsonDecode(quizJson) as Map<String, dynamic>;
      final quizModel = QuizGroupRemoteModel.fromJson(parsed);
      // Validasi group quiz:
      final groupIds = quizModel.groups?.map((g) => g.id).toSet() ?? {};
      if (quizModel.groups == null ||
          quizModel.groups!.length != 2 ||
          quizModel.options == null ||
          quizModel.options!.length != 8 ||
          quizModel.options!.any((o) => !groupIds.contains(o.correctGroupId))) {
        EpicLog.debug('_tryToGenerateGroupQuiz - invalid quiz structure');
        return null;
      }
      final quizEntity = QuizGroupMapper.remoteToEntity(quizModel);
      return quizEntity.copyWith(
        quizDataHelper: quizModel.toJson().toString(),
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryToGenerateGroupQuiz');
    }
    return null;
  }

  Future<void> closePage() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Get.back(result: bookHistory.value);
  }

  void openBookRewardClaim() async {
    await Get.toNamed(
      EpicRoutes.bookReward,
      arguments: currentBook.value,
    );
  }
}
