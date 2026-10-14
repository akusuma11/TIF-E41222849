import 'dart:convert';

import 'package:epic_story_app/core/constants/quiz_prompt.dart';
import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_choice_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_fill_blank_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_group_mapper.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_choice_remote_model.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_fill_blank_remote_model.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_group_remote_model.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_card_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_answer_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_card_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_quiz_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_choice_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_fill_blank_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_group_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/quiz_usecase.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/quiz/group_quiz.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/quiz/fill_blank_quiz.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/quiz/multiple_choice_quiz.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_quiz_controller.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class FlashcardReadController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late FlashcardEntity flashcard;
  var flashcardHistory = Rxn(FlashcardHistoryEntity());

  final currentCard = Rxn<FlashcardCardEntity>();
  final currentText = ''.obs;
  final currentImage = RxnString();
  final isQuizCard = false.obs;

  final isLoading = false.obs;
  var isSoundOn = true.obs;

  final currentIndex = 0.obs;
  final isBookmarked = false.obs;
  final dragOffset = 0.0.obs;
  final isFlipping = false.obs;
  final flipDirection = 1.obs; // 1: next, -1: prev
  final pendingIndex = RxnInt();
  final hasSwapped = false.obs;
  final highlightedStart = RxnInt();
  final highlightedEnd = RxnInt();
  final ttsBaseOffset = RxnInt();

  final FlutterTts _tts = FlutterTts();

  late AnimationController flipController;
  late Animation<double> flipAnimation;
  final navController = Get.find<EpicNavigationController>();

  List<FlashcardCardEntity> get cards => flashcard.cards ?? [];
  int get totalCards => cards.isEmpty ? 1 : cards.length;

  FlashcardCardEntity? get currentCardEntity => currentCard.value;

  bool get isQuiz => isQuizCard.value;

  double get progress => (currentIndex.value + 1) / totalCards;

  final ChildrenUsecase childrenUsecase;
  final CollectionUsecase collectionUsecase;
  final QuizUsecase quizUsecase;

  FlashcardReadController({
    required this.childrenUsecase,
    required this.collectionUsecase,
    required this.quizUsecase,
  });

  var collections = <FlashCardCollectionEntity>[].obs;

  final mainController = Get.find<MainController>();
  late final FlashcardQuizController quizController;
  var retryQuestion = 3.obs;

  var allTextTheory = ''.obs; // berisi gabungan semua teks dari kartu

  @override
  void onClose() {
    _stopTts();
    flipController.dispose();
    pushHistoryToFirestore();
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();

    quizController =
        Get.put(FlashcardQuizController(flashcardReadController: this));

    flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    flipAnimation = CurvedAnimation(
      parent: flipController,
      curve: Curves.easeInOutCubicEmphasized,
    );

    flipController.addListener(_handleFlipMidpoint);
    flipController.addStatusListener(_handleFlipStatus);
    _initTts();

    await _initBook();
    _syncCurrentCard();
    updateHistory();
    ever<int>(currentIndex, (_) => _syncCurrentCard());
    ever<FlashcardHistoryEntity?>(flashcardHistory, (_) => _refreshQuizMeta());
    var children = await childrenUsecase.getChildrenRemoteModel();
    collections.value = children?.flashcardCollections ?? [];
  }

  Future<void> updateHistory() async {
    try {
      var history = flashcardHistory.value;
      var historyCard = history?.cards;

      bool isExist = historyCard != null &&
          historyCard.any((card) => card.nPage == currentCard.value?.nPage);
      final quizType = currentCard.value?.quizType ?? 0;
      if (!isExist) {
        history = history?.copyWith(
          cards: [
            ...?historyCard,
            FlashcardHistoryCardEntity(
              nPage: currentCard.value?.nPage ?? 0,
              isRead: true,
              isQuiz: quizType > 0,
            )
          ],
        );
        flashcardHistory.value = history;
      } else {
        history = history?.copyWith(
          cards: historyCard.map((card) {
            if (card.nPage == currentCard.value?.nPage) {
              return card.copyWith(isRead: true, isQuiz: quizType > 0);
            }
            return card;
          }).toList(),
        );
        flashcardHistory.value = history;
      }
      if (history != null) {
        var totalCard = history.totalCards ?? 0;
        var totalQuiz = history.totalQuiz ?? 0;
        var completedQuiz = history.completedQuiz ?? 0;
        var isAllQuizCompleted = (completedQuiz >= totalQuiz);
        var readPages = (history.cards?.length ?? 0) + 1;
        var isAllRead = readPages >= totalCard;
        EpicLog.debug(
            "updateHistory - totalCard: $totalCard, totalQuiz: $totalQuiz, completedQuiz: $completedQuiz, readPages: $readPages, isAllRead: $isAllRead, isAllQuizCompleted: $isAllQuizCompleted");
        var isFinished = isAllRead && isAllQuizCompleted;
        var updatedHistory = history.copyWith(
          lastReadAt: DateTime.now(),
          isFinished: isFinished,
          finishedAt: currentIndex.value == totalCards - 1
              ? DateTime.now()
              : history.finishedAt,
        );
        bool result = await childrenUsecase.updateFlashcardHistory(
          flashcardHistory: updatedHistory,
        );
        EpicLog.debug(
            'updateHistory<testing> - updateFlashcardHistory result: $result');
        flashcardHistory.value = updatedHistory;
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, 'Error reading flashcard page');
    }
  }

  void _handleFlipMidpoint() {
    // Swap content when rotation passes halfway to avoid mirrored text.
    if (!hasSwapped.value && flipAnimation.value >= 0.5) {
      final target = pendingIndex.value;
      if (target != null && target >= 0 && target < totalCards) {
        currentIndex.value = target;
        _syncCurrentCard();
        updateHistory();
      }
      hasSwapped.value = true;
    }
  }

  void _handleFlipStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _resetFlipState();
    }
  }

  void _resetFlipState() {
    isFlipping.value = false;
    pendingIndex.value = null;
    hasSwapped.value = false;
    dragOffset.value = 0;
    if (flipController.status != AnimationStatus.dismissed) {
      flipController.reset();
    }
  }

  Future<void> _initBook() async {
    try {
      isLoading.value = true;
      final args = Get.arguments;
      if (args is FlashcardEntity) {
        flashcard = args;
        var history = await childrenUsecase.getFlashcardHistoryById(
          flashcard.flashcardId ?? '',
        );
        if (history != null) {
          flashcardHistory.value = history.copyWith(
            lastReadAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        } else {
          flashcardHistory.value = FlashcardHistoryEntity(
            flashcardId: flashcard.flashcardId ?? '',
            title: flashcard.title,
            summary: flashcard.summary,
            category: flashcard.category,
            totalCards: flashcard.cards?.length ?? 0,
            totalQuiz: flashcard.totalQuiz ?? 0,
            isHaveQuiz: flashcard.isHaveQuiz ?? false,
            updatedAt: DateTime.now(),
            lastReadAt: DateTime.now(),
            isFinished: false,
            finishedAt: null,
            cards: [],
            completedQuiz: 0,
          );
        }
        EpicLog.debug(
            'Initialized FlashcardReadController with flashcard: ${flashcard.title}, total cards: ${flashcard.cards?.length ?? 0}');
        _buildAllTextTheory();
        await generateQuiz();
      } else {
        Get.back();
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_initBook');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pushHistoryToFirestore() async {
    try {
      var history = flashcardHistory.value;
      if (history != null) {
        await childrenUsecase.updateFlashcardHistory(
          flashcardHistory: history,
          pushToRemote: true,
        );
        flashcardHistory.value = history;
        // navController.refresRewardFlashcard.value++;
        if (history.isFinished == true &&
            history.claimedRewards != null &&
            history.claimedRewards!.isEmpty) {
          // navController.refresRewardFlashcard.value++;
        }
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, 'Error pushing flashcard history to Firestore');
    }
  }

  Future<void> updateHistoryQuestion({
    required int quizType,
    required FlashcardCardEntity card,
    QuizChoiceEntity? multipleChoiceQuestion,
    QuizGroupEntity? groupQuestion,
    QuizFillBlankEntity? fillBlankQuestion,
  }) async {
    try {
      final currentCard = card;

      final history = flashcardHistory.value;
      if (history == null) return;

      EpicLog.debug(
          'updateHistoryQuestion - 1Updating history for card nPage: ${currentCard.nPage}, quizType: $quizType, retry: 3');

      final cardHistoryIndex = history.cards?.indexWhere(
        (h) => h.nPage == currentCard.nPage,
      );
      if (cardHistoryIndex == null || cardHistoryIndex < 0) return;

      final cardHistory = history.cards![cardHistoryIndex];

      EpicLog.debug(
          'updateHistoryQuestion - 2Updating history for card nPage: ${currentCard.nPage}, quizType: $quizType, retry: 3');
      final existingAnswer = cardHistory.historyAnswer;
      final baseAnswer = existingAnswer ??
          FlashcardHistoryAnswerEntity(
            quizType: quizType,
            retry: 3,
          );

      String? explanation;
      var updatedAnswer = baseAnswer.copyWith(
        quizType: quizType,
        retry: 3,
        answer: existingAnswer?.answer,
      );

      if (quizType == 1 && multipleChoiceQuestion != null) {
        updatedAnswer = updatedAnswer.copyWith(
          multipleChoiceQuestion: multipleChoiceQuestion,
          multipleChoiceAnswer: null,
          forceAnswerNull: true,
        );
        explanation = multipleChoiceQuestion.explanation;
      } else if (quizType == 2 && fillBlankQuestion != null) {
        updatedAnswer = updatedAnswer.copyWith(
          fillBlankQuestion: fillBlankQuestion,
          fillBlankAnswer: null,
          forceAnswerNull: true,
        );
        explanation = fillBlankQuestion.explanation;
      } else if (quizType == 3 && groupQuestion != null) {
        updatedAnswer = updatedAnswer.copyWith(
          groupQuestion: groupQuestion,
          groupAnswer: null,
          forceAnswerNull: true,
        );
        explanation = groupQuestion.explanation;
      }

      final updatedCardHistory = cardHistory.copyWith(
        isQuizAlreadyGenerated: true,
        historyAnswer: updatedAnswer,
      );

      var updatedCards = [...?history.cards];
      updatedCards[cardHistoryIndex] = updatedCardHistory;

      for (var c in updatedCards) {
        EpicLog.debug(
            'updateHistoryQuestion - card nPage: ${c.nPage}, isQuiz: ${c.isQuiz}, historyAnswer: ${c.historyAnswer}');
      }

      final updatedHistory = history.copyWith(cards: updatedCards);
      EpicLog.debug(
          'updateHistoryQuestion - 3Updating history for card nPage: ${currentCard.nPage}, quizType: $quizType, retry: ${retryQuestion.value}');
      bool result = await childrenUsecase.updateFlashcardHistory(
        flashcardHistory: updatedHistory,
      );
      EpicLog.debug('updateHistoryQuestion - result: $result');
      flashcardHistory.value = updatedHistory;
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'updateHistoryQuestion');
    }
  }

  void _buildAllTextTheory() {
    final texts = flashcard.cards
            ?.map((card) => card.text?.trim())
            .where((text) => text != null && text.isNotEmpty)
            .map((text) => text!)
            .toList() ??
        [];

    allTextTheory.value = texts.join('\n');
    EpicLog.debug(
        'Built allTextTheory : line count: ${texts.length} | ${allTextTheory.value} | ');
  }

  Future<void> generateQuiz({
    bool forceGenerate = false,
  }) async {
    try {
      if (forceGenerate) {
        isLoading.value = true;
      }
      var text = allTextTheory.value;
      var currentFlashcard = flashcard;
      var currentHistory = flashcardHistory.value;
      var quizIndexes = currentFlashcard.cards
              ?.where((card) => card.quizType != null)
              .map((card) => card.nPage)
              .toList() ??
          [];
      if (currentFlashcard.isGenerateQuizSupported == true) {
        var cardHis = currentHistory?.cards ?? <FlashcardHistoryCardEntity>[];
        var cards = currentFlashcard.cards ?? <FlashcardCardEntity>[];
        for (var card in cards) {
          var isQuiz = quizIndexes.contains(card.nPage);
          if (isQuiz) {
            var historyCard = cardHis.firstWhereOrNull(
              (h) => h.nPage == card.nPage,
            );
            if (historyCard == null) {
              EpicLog.debug('generateQuiz - user belum pernah membaca ini');
              EpicLog.debug('generateQuiz - ready for generate');
              var newHistoryCard = FlashcardHistoryCardEntity(
                nPage: card.nPage,
                isRead: false,
                isQuiz: true,
                completedQuiz: false,
                correctAnswer: false,
                isQuizAlreadyGenerated: false,
              );
              var history = flashcardHistory.value;
              var historyCard = history?.cards;

              history = history?.copyWith(
                cards: [
                  ...?historyCard,
                  newHistoryCard,
                ],
              );

              if (history != null) {
                await childrenUsecase.updateFlashcardHistory(
                  flashcardHistory: history,
                );
                flashcardHistory.value = history;
                var quizType = card.quizType ?? 0;
                bool isGenerated = await _tryGenerateQuizByQuizType(
                  quizType: quizType,
                  text: text,
                  card: card,
                  category: flashcard.category,
                  previousQuestions: _extractPreviousQuestionsFromCard(card),
                );
                if (isGenerated) {
                  EpicLog.debug('generateQuiz - quiz generated successfully');
                  _sycnronizedQuizDataWithHistory(card);
                }
              } else {
                EpicLog.debug(
                    "generateQuiz - failed generate - history is null");
              }
            } else {
              var his = historyCard;
              var isQuiz = his.isQuiz == true;
              var isNotCompleted = his.completedQuiz != true;
              var totalRetry = his.historyAnswer?.retry ?? 3;
              var isQuizAlreadyGenerated = his.isQuizAlreadyGenerated == true;
              var firstAnswer = totalRetry == 3;
              var quizType = card.quizType ?? 0;
              var isCanGenerate = isQuiz &&
                  isNotCompleted &&
                  firstAnswer &&
                  !isQuizAlreadyGenerated;
              EpicLog.debug('generateQuiz - user sudah pernah membaca ini');
              if (isCanGenerate || forceGenerate) {
                EpicLog.debug(
                    'generateQuiz - ready for generate with force generate: $forceGenerate');
                var isGenerated = await _tryGenerateQuizByQuizType(
                  quizType: quizType,
                  text: text,
                  card: card,
                  category: flashcard.category,
                  previousQuestions: forceGenerate
                      ? _extractPreviousQuestionsFromCard(card)
                      : const [],
                );
                if (isGenerated) {
                  EpicLog.debug('generateQuiz - quiz generated successfully');
                  _sycnronizedQuizDataWithHistory(card);
                  if (forceGenerate) {
                    EpicSnackBar.showSuccessSnackBar(
                      "Success",
                      "Quiz generated successfully",
                    );
                    _syncCurrentCard();
                    quizController.resetState();
                    // quizController.syncCurrentQuiz();
                  }
                }
              } else {
                EpicLog.debug('generateQuiz - rejected for generate');
                _sycnronizedQuizDataWithHistory(card);
              }
            }
          }
        }
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'generateQuiz');
    } finally {
      if (forceGenerate) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _updateCardQuiz({
    required FlashcardCardEntity card,
    QuizChoiceEntity? choiceQuiz,
    QuizFillBlankEntity? fillBlankQuiz,
    QuizGroupEntity? groupQuiz,
  }) async {
    var quizType = card.quizType;
    final cards = flashcard.cards ?? <FlashcardCardEntity>[];
    final targetIndex = cards.indexWhere((c) => c.nPage == card.nPage);
    if (targetIndex < 0) {
      return;
    }

    final explanationFallback = card.quiz?.explanation;

    FlashcardQuizEntity? updatedQuiz;
    if (quizType == 1 && choiceQuiz != null) {
      updatedQuiz = FlashcardQuizEntity(
        quizType: quizType,
        quizData: choiceQuiz.quizDataHelper,
        explanation: choiceQuiz.explanation ?? explanationFallback,
        multipleChoice: choiceQuiz,
      );
    } else if (quizType == 2 && fillBlankQuiz != null) {
      updatedQuiz = FlashcardQuizEntity(
        quizType: quizType,
        quizData: fillBlankQuiz.quizDataHelper,
        explanation: fillBlankQuiz.explanation ?? explanationFallback,
        fillBlank: fillBlankQuiz,
      );
    } else if (quizType == 3 && groupQuiz != null) {
      updatedQuiz = FlashcardQuizEntity(
        quizType: quizType,
        quizData: groupQuiz.quizDataHelper,
        explanation: groupQuiz.explanation ?? explanationFallback,
        group: groupQuiz,
      );
    } else {
      return;
    }

    final updatedCard = cards[targetIndex].copyWith(quiz: updatedQuiz);
    final updatedCards = List<FlashcardCardEntity>.from(cards);
    updatedCards[targetIndex] = updatedCard;

    EpicLog.debug(
        '_updateCardQuiz - Updating flashcard card with new quiz data for nPage: ${card.nPage}, quizType: $quizType');
    flashcard = flashcard.copyWith(cards: updatedCards);
  }

  List<String> _extractPreviousQuestionsFromCard(FlashcardCardEntity card) {
    final quiz = card.quiz;
    if (quiz == null) return [];
    final List<String> previous = [];
    if (quiz.multipleChoice?.question != null) {
      previous.add(quiz.multipleChoice!.question!);
    }
    if (quiz.fillBlank?.sentence != null) {
      final sentenceText = quiz.fillBlank!.sentence!
          .map((s) => s.type == 'blank' ? '___' : (s.value ?? ''))
          .join();
      if (sentenceText.trim().isNotEmpty) previous.add(sentenceText);
    }
    if (quiz.group?.groups != null) {
      final groupTitles = quiz.group!.groups!
          .map((g) => g.title ?? '')
          .where((t) => t.isNotEmpty)
          .join(' vs ');
      if (groupTitles.isNotEmpty) previous.add('Kelompokkan: $groupTitles');
    }
    return previous;
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

      if (quizJson == null) {
        EpicLog.debug('_tryToGenerateMultipleChoiceQuiz - quizJson is null');
        return null;
      }

      final parsed = jsonDecode(quizJson) as Map<String, dynamic>;

      var quizModel = QuizChoiceRemoteModel.fromJson(parsed);

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

      var quizEntity = QuizChoiceMapper.remoteToEntity(quizModel);

      EpicLog.debug('generateQuiz - quizJson: $quizJson');
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

      if (quizJson == null) {
        EpicLog.debug('_tryToGenerateFillBlankQuiz - quizJson is null');
        return null;
      }

      final parsed = jsonDecode(quizJson) as Map<String, dynamic>;

      var quizModel = QuizFillBlankRemoteModel.fromJson(parsed);

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

      var quizEntity = QuizFillBlankMapper.remoteToEntity(quizModel);

      EpicLog.debug('generateQuiz - quizJson: $quizJson');
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

      if (quizJson == null) {
        EpicLog.debug('_tryToGenerateGroupQuiz - quizJson is null');
        return null;
      }

      final parsed = jsonDecode(quizJson) as Map<String, dynamic>;

      var quizModel = QuizGroupRemoteModel.fromJson(parsed);

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

      var quizEntity = QuizGroupMapper.remoteToEntity(quizModel);

      EpicLog.debug('generateQuiz - quizJson: $quizJson');
      return quizEntity.copyWith(
        quizDataHelper: quizModel.toJson().toString(),
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryToGenerateGroupQuiz');
    }
    return null;
  }

  Future<bool> _tryGenerateQuizByQuizType({
    required int quizType,
    required String text,
    required FlashcardCardEntity card,
    String? category,
    List<String> previousQuestions = const [],
  }) async {
    try {
      if (quizType == 1) {
        var choiceQuiz = await _tryToGenerateMultipleChoiceQuiz(
          fullText: text,
          category: category,
          previousQuestions: previousQuestions,
        );
        if (choiceQuiz != null) {
          await updateHistoryQuestion(
            quizType: quizType,
            multipleChoiceQuestion: choiceQuiz,
            card: card,
          );
          _updateCardQuiz(
            card: card,
            choiceQuiz: choiceQuiz,
          );
          return true;
        }
      } else if (quizType == 2) {
        var fillBlankQuiz = await _tryToGenerateFillBlankQuiz(
          fullText: text,
          category: category,
          previousQuestions: previousQuestions,
        );
        if (fillBlankQuiz != null) {
          await updateHistoryQuestion(
            quizType: quizType,
            fillBlankQuestion: fillBlankQuiz,
            card: card,
          );
          _updateCardQuiz(
            card: card,
            fillBlankQuiz: fillBlankQuiz,
          );
          return true;
        }
      } else if (quizType == 3) {
        var groupQuiz = await _tryToGenerateGroupQuiz(
          fullText: text,
          category: category,
          previousQuestions: previousQuestions,
        );
        if (groupQuiz != null) {
          await updateHistoryQuestion(
            quizType: quizType,
            groupQuestion: groupQuiz,
            card: card,
          );
          _updateCardQuiz(
            card: card,
            groupQuiz: groupQuiz,
          );
          return true;
        }
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryGenerateQuizByQuizType');
    }
    return false;
  }

  Future<void> goToResult() async {
    await Get.toNamed(
      EpicRoutes.flashCardResult,
      arguments: flashcard,
    );
    flashcardHistory.value = await childrenUsecase.getFlashcardHistoryById(
      flashcard.flashcardId ?? '',
    );
  }

  void goNext() async {
    if (isFlipping.value) return;
    if (currentIndex.value >= totalCards - 1) {
      if (flashcardHistory.value?.isFinished == true) {
        await updateHistory();
        await goToResult();
        return;
      } else {
        EpicSnackBar.showWarningSnackBar(
            "Warning", "Selesaikan quiz untuk mendapatkan reward");
      }
      return;
    }
    _startFlip(targetIndex: currentIndex.value + 1, direction: 1);
  }

  void goPrev() {
    if (isFlipping.value) return;
    if (currentIndex.value <= 0) return;
    _startFlip(targetIndex: currentIndex.value - 1, direction: -1);
  }

  void jumpToIndex(int index) {
    if (isFlipping.value) return;
    if (index < 0 || index >= totalCards) return;
    if (index == currentIndex.value) return;
    final direction = index > currentIndex.value ? 1 : -1;
    _startFlip(targetIndex: index, direction: direction);
  }

  void toggleBookmark() {
    isBookmarked.toggle();
  }

  void updateDrag(double deltaX) {
    if (isFlipping.value) return;
    // Clamp to keep animation reasonable
    dragOffset.value = (dragOffset.value + deltaX).clamp(-320.0, 320.0);
  }

  void endDrag() {
    if (isFlipping.value) {
      dragOffset.value = 0;
      return;
    }
    final dx = dragOffset.value;
    if (dx > 120) {
      goPrev();
    } else if (dx < -120) {
      goNext();
    }
    dragOffset.value = 0;
  }

  void _syncCurrentCard() {
    if (cards.isEmpty) {
      currentCard.value = null;
      currentText.value = _placeholderText;
      currentImage.value = null;
      _refreshQuizMeta();
    } else {
      final card = cards[currentIndex.value];
      currentCard.value = card;
      currentText.value = card.text ?? _placeholderText;
      currentImage.value = card.image;
      _refreshQuizMeta();
    }
    quizController.resetState();
    quizController.syncCurrentQuiz();
    _clearHighlight();
    _autoReadIfAllowed();
  }

  void _refreshQuizMeta() {
    final card = currentCard.value;
    if (card == null) {
      isQuizCard.value = false;
      retryQuestion.value = 3;
      return;
    }

    final hasQuiz = (card.quiz?.quizData != null);
    isQuizCard.value = hasQuiz;

    if (hasQuiz) {
      final historyAnswer = flashcardHistory.value?.cards
          ?.firstWhereOrNull((h) => h.nPage == card.nPage);
      retryQuestion.value = historyAnswer?.historyAnswer?.retry ?? 3;
    } else {
      retryQuestion.value = 3;
    }
  }

  void _startFlip({required int targetIndex, required int direction}) {
    if (targetIndex == currentIndex.value ||
        targetIndex < 0 ||
        targetIndex >= totalCards) {
      return;
    }
    pendingIndex.value = targetIndex;
    flipDirection.value = direction;
    isFlipping.value = true;
    hasSwapped.value = false;
    flipController.forward(from: 0);
  }

  static const String _placeholderText = 'Quiz??';

  Future<void> addFlashcardToCollection({
    required String collectionId,
    required String flashcardId,
  }) async {
    try {
      Get.back();
      mainController.showLoadingPage();
      await collectionUsecase.addFlashcardToCollection(
        collectionId: collectionId,
        flashcardId: flashcardId,
      );
      navController.refreshCollectionHome.value++;
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'addFlashcardToCollection');
    } finally {
      mainController.hideLoadingPage();
    }
  }

  void _sycnronizedQuizDataWithHistory(FlashcardCardEntity card) {
    final quizType = card.quizType;
    if (quizType == null) return;

    final historyCard = flashcardHistory.value?.cards
        ?.firstWhereOrNull((h) => h.nPage == card.nPage);
    if (historyCard == null) return;

    final historyAnswer = historyCard.historyAnswer;
    if (historyAnswer == null) {
      EpicLog.debug(
          '_sycnronizedQuizDataWithHistory - historyAnswer is null for card nPage: ${card.nPage}');
      return;
    }

    if (quizType == 1) {
      final quizEntity = historyAnswer.multipleChoiceQuestion;
      EpicLog.debug(
          '_sycnronizedQuizDataWithHistory - quizEntity from history: ${quizEntity?.question}');
      if (quizEntity != null) {
        var tempRemote = QuizChoiceMapper.entityToRemote(quizEntity);
        _updateCardQuiz(
          card: card,
          choiceQuiz: quizEntity.copyWith(
            quizDataHelper: tempRemote.toJson().toString(),
          ),
        );
      }
    } else if (quizType == 2) {
      final quizEntity = historyAnswer.fillBlankQuestion;
      if (quizEntity != null) {
        var tempRemote = QuizFillBlankMapper.entityToRemote(quizEntity);
        _updateCardQuiz(
          card: card,
          fillBlankQuiz: quizEntity.copyWith(
            quizDataHelper: tempRemote.toJson().toString(),
          ),
        );
      }
    } else if (quizType == 3) {
      final quizEntity = historyAnswer.groupQuestion;
      if (quizEntity != null) {
        var tempRemote = QuizGroupMapper.entityToRemote(quizEntity);
        _updateCardQuiz(
          card: card,
          groupQuiz: quizEntity.copyWith(
            quizDataHelper: tempRemote.toJson().toString(),
          ),
        );
      }
    }
  }

  Widget getQuizWidget() {
    if (currentCard.value?.quizType == 1) {
      var cardSakIki = currentCard.value;
      var quizData = cardSakIki?.quiz?.multipleChoice;
      var quizDataFromHistory = flashcardHistory.value?.cards
          ?.firstWhereOrNull((h) => h.nPage == cardSakIki?.nPage)
          ?.historyAnswer;
      var quizDataHistory = quizDataFromHistory?.multipleChoiceQuestion;

      if (quizData != null) {
        return MultipleChoiceQuiz(
          quizController: quizController,
          quizData: quizDataHistory ?? quizData,
        );
      } else {
        return const Text("QUIZ DATA NULL");
      }
    }
    if (currentCard.value?.quizType == 2) {
      var quizData = currentCard.value?.quiz?.fillBlank;
      var quizDataFromHistory = flashcardHistory.value?.cards
          ?.firstWhereOrNull((h) => h.nPage == currentCard.value?.nPage)
          ?.historyAnswer;
      var quizDataHistory = quizDataFromHistory?.fillBlankQuestion;
      if (quizData != null) {
        return FillBlankQuiz(
          quizController: quizController,
          quizData: quizDataHistory ?? quizData,
        );
      } else {
        return const Text("QUIZ DATA NULL");
      }
    }
    if (currentCard.value?.quizType == 3) {
      var quizData = currentCard.value?.quiz?.group;
      var quizDataFromHistory = flashcardHistory.value?.cards
          ?.firstWhereOrNull((h) => h.nPage == currentCard.value?.nPage)
          ?.historyAnswer;
      var quizDataHistory = quizDataFromHistory?.groupQuestion;
      if (quizData != null) {
        return GroupQuiz(
          quizController: quizController,
          quizData: quizDataHistory ?? quizData,
        );
      } else {
        return const Text("QUIZ DATA NULL");
      }
    }
    // Add more quiz types here as needed
    return const SizedBox.shrink();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.55);
    await _tts.setPitch(1.0);

    _tts.setProgressHandler((text, start, end, word) {
      final base = ttsBaseOffset.value ?? 0;
      highlightedStart.value = base + start;
      highlightedEnd.value = base + end;
    });

    _tts.setCompletionHandler(() {
      _clearHighlight();
      ttsBaseOffset.value = null;
    });

    _tts.setCancelHandler(() {
      _clearHighlight();
      ttsBaseOffset.value = null;
    });
  }

  Future<void> _autoReadIfAllowed() async {
    if (!isSoundOn.value || isQuizCard.value) {
      await _stopTts();
      return;
    }
    final text = currentText.value.trim();
    if (text.isEmpty || text == _placeholderText) {
      await _stopTts();
      return;
    }
    await _speak(text);
  }

  Future<void> _speak(String text, {int baseOffset = 0}) async {
    await _stopTts();
    _clearHighlight();
    ttsBaseOffset.value = baseOffset;
    await _tts.speak(text);
  }

  Future<void> speakWordAt(int start, int end) async {
    if (isQuizCard.value) return;
    final text = currentText.value;
    if (start < 0 || end > text.length || start >= end) return;
    final word = text.substring(start, end).trim();
    if (word.isEmpty) return;
    highlightedStart.value = start;
    highlightedEnd.value = end;
    await _stopTts();
    await _speak(word, baseOffset: start);
  }

  Future<void> _stopTts() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _clearHighlight();
    ttsBaseOffset.value = null;
  }

  void toggleSound() {
    isSoundOn.toggle();
    if (isSoundOn.value) {
      _autoReadIfAllowed();
    } else {
      _stopTts();
    }
  }

  void _clearHighlight() {
    highlightedStart.value = null;
    highlightedEnd.value = null;
  }
}
