import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:epic_story_app/core/constants/quiz_prompt.dart';
import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_choice_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_fill_blank_mapper.dart';
import 'package:epic_story_app/data/models/mappers/quiz/quiz_group_mapper.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_choice_remote_model.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_fill_blank_remote_model.dart';
import 'package:epic_story_app/data/models/remotes/quiz/quiz_group_remote_model.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/domain/entities/book_history_quiz_entity.dart';
import 'package:epic_story_app/domain/entities/children_collection_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_choice_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_fill_blank_entity.dart';
import 'package:epic_story_app/domain/entities/quiz/quiz_group_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/quiz_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';

class BookReadController extends GetxController {
  late BookEntity book;
  final Rxn<BookHistoryEntity> bookHistory = Rxn<BookHistoryEntity>();
  final collections = <ChildrenCollectionEntity>[].obs;

  final RxInt currentIndex = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPdfLoading = false.obs;
  final RxnString pdfPath = RxnString();
  final RxnString error = RxnString();
  final Rxn<PDFViewController> pdfController = Rxn<PDFViewController>();
  final RxBool isSoundOn = true.obs;
  final Stopwatch _readingTimer = Stopwatch();
  final FlutterTts _tts = FlutterTts();
  final List<int> _visiblePdfPages =
      <int>[]; // PDF page indexes that are allowed to show
  final Map<int, int> _pdfToVisibleIndex =
      <int, int>{}; // PDF index -> visible index
  final Map<int, String> _pageTextByPdfIndex = <int, String>{};
  int _pdfTotalPages = 0;
  int _lastPdfPage = -1;
  DateTime _sessionStartedAt = DateTime.now();
  int _initialReadingSeconds = 0;
  bool _isBookInitialized = false;
  bool _isBootstrapping = false;
  bool _isDisposing = false;
  bool _isPersistingHistory = false;
  bool _pendingPersistHistory = false;
  int _pageChangeTicket = 0;
  Timer? _persistDebounce;
  var allTextTheory = ''.obs; // berisi gabungan semua teks dari kartu

  static const Duration _historyTimeout = Duration(seconds: 8);
  static const Duration _collectionRemoteTimeout = Duration(seconds: 10);
  static const Duration _collectionMutationTimeout = Duration(seconds: 12);
  static const Duration _quizGenerationTimeout = Duration(seconds: 14);

  final navController = Get.find<EpicNavigationController>();
  final mainController = Get.find<MainController>();

  final ChildrenUsecase childrenUsecase;
  final QuizUsecase quizUsecase;
  final CollectionUsecase collectionUsecase;

  BookReadController({
    required this.childrenUsecase,
    required this.quizUsecase,
    required this.collectionUsecase,
  });

  @override
  void onClose() {
    _isDisposing = true;
    _persistDebounce?.cancel();
    _readingTimer.stop();
    pdfController.value = null;
    _visiblePdfPages.clear();
    _pdfToVisibleIndex.clear();
    _pageTextByPdfIndex.clear();
    unawaited(_stopTts(force: true));
    unawaited(pushHistoryToFirestore());
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _sessionStartedAt = DateTime.now();
    _readingTimer.start();
    loadBook();
  }

  Future<void> loadBook() async {
    if (_isBootstrapping) return;
    _isBootstrapping = true;

    try {
      var arg = Get.arguments;
      if (arg is BookEntity) {
        book = arg;
        _isBookInitialized = true;
      } else {
        throw ArgumentError('Expected BookEntity as argument');
      }

      isLoading.value = true;
      error.value = null;

      // Keep the screen responsive: PDF is loaded in background.
      isPdfLoading.value = true;
      unawaited(_loadPdf().whenComplete(() {
        if (!isClosed) {
          isPdfLoading.value = false;
        }
      }));

      await Future.wait([
        initBookHistory().timeout(
          _historyTimeout,
          onTimeout: () {
            EpicLog.warn(
                'initBookHistory timeout, continue with default state');
          },
        ),
        _loadCollectionsFromLocal(),
      ]);

      // Refresh collections from remote in background; UI should not block for this.
      unawaited(_refreshCollectionsFromRemote());

      _buildAllTextTheory();

      // Quiz generation is optional; run in background with timeout.
      unawaited(_generateQuizSafely());
      _initTts();
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'loadBook');
      if (!isClosed && error.value == null) {
        error.value = 'Gagal memuat buku';
      }
    } finally {
      if (!isClosed) {
        isLoading.value = false;
      }
      _isBootstrapping = false;
    }
  }

  Future<void> _loadCollectionsFromLocal() async {
    try {
      final children = await childrenUsecase
          .getCurrentChildren()
          .timeout(const Duration(seconds: 3));
      if (!isClosed) {
        collections.assignAll(children?.collections ?? []);
      }
    } on TimeoutException {
      EpicLog.warn('_loadCollectionsFromLocal timeout');
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_loadCollectionsFromLocal');
    }
  }

  Future<void> _refreshCollectionsFromRemote() async {
    try {
      final children = await mainController.childrenUsecase
          .getChildrenRemoteModel()
          .timeout(_collectionRemoteTimeout);
      if (!isClosed) {
        collections.assignAll(children?.collections ?? []);
      }
    } on TimeoutException {
      EpicLog.warn('_refreshCollectionsFromRemote timeout');
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_refreshCollectionsFromRemote');
    }
  }

  Future<void> _generateQuizSafely() async {
    try {
      await generateQuiz().timeout(
        _quizGenerationTimeout,
        onTimeout: () {
          EpicLog.warn('generateQuiz timeout, skipped for this session');
        },
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_generateQuizSafely');
    }
  }

  Future<void> initBookHistory() async {
    try {
      final bookId = book.bookId;
      if (bookId == null || bookId.isEmpty) return;

      final existing = await childrenUsecase.getBookHistoryById(bookId);
      if (existing != null) {
        bookHistory.value = existing;
        _initialReadingSeconds = existing.totalReadingSeconds ?? 0;
      }
      await _persistBookHistory();
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_initBookHistory');
    }
  }

  void setInitialSound(bool value) {
    isSoundOn.value = value;
  }

  Future<void> onPageChanged(int index) async {
    if (_isDisposing || isClosed) return;
    final ticket = ++_pageChangeTicket;

    await _stopTts();
    if (_isDisposing || isClosed || ticket != _pageChangeTicket) return;

    if (_visiblePdfPages.isEmpty && _pdfTotalPages > 0) {
      _rebuildVisiblePages(_pdfTotalPages);
    }

    final visibleIndex = _pdfToVisibleIndex[index];
    if (visibleIndex != null) {
      _lastPdfPage = index;
      currentIndex.value = visibleIndex;
      _debouncedPersistHistory();
      if (_isDisposing || isClosed || ticket != _pageChangeTicket) return;
      await _speakCurrentVisibleText();
      return;
    }

    final direction = index >= _lastPdfPage ? 1 : -1;
    final target = _nextVisiblePdf(index, direction);
    if (target != null && target != index) {
      _lastPdfPage = target;
      pdfController.value?.setPage(target);
      return;
    }
  }

  void _debouncedPersistHistory() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(seconds: 2), () {
      if (!_isDisposing && !isClosed) {
        _persistBookHistory();
      }
    });
  }

  void setTotalPages(int total) {
    if (_isDisposing || isClosed) return;
    final sanitizedTotal = total.clamp(0, 10000).toInt();
    if (_pdfTotalPages == sanitizedTotal && _visiblePdfPages.isNotEmpty) {
      return;
    }
    _pdfTotalPages = sanitizedTotal;
    _rebuildVisiblePages(_pdfTotalPages);
  }

  void toggleSound() {
    isSoundOn.toggle();
    if (isSoundOn.value) {
      _speakCurrentVisibleText();
    } else {
      _stopTts();
    }
  }

  Future<void> goTo(int index) async {
    final controller = pdfController.value;
    if (controller == null) return;
    if (_visiblePdfPages.isEmpty) return;
    if (index < 0 || index >= _visiblePdfPages.length) return;
    await _stopTts();
    final pdfPage = _visiblePdfPages[index];
    await controller.setPage(pdfPage);
  }

  void onPdfViewCreated(PDFViewController controller) {
    if (_isDisposing || isClosed) return;
    pdfController.value = controller;
  }

  Future<void> _loadPdf() async {
    if (isClosed) return;
    error.value = null;
    pdfPath.value = null;
    currentIndex.value = 0;

    try {
      final url = book.bookAsset;
      if (url == null || url.isEmpty) {
        error.value = 'Book asset tidak tersedia';
        return;
      }

      // Check cache first — avoid re-downloading if PDF already on disk.
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/book_${book.bookId ?? 'temp'}.pdf');
      if (await file.exists()) {
        final fileSize = await file.length();
        if (fileSize > 0) {
          if (!isClosed) {
            pdfPath.value = file.path;
          }
          return;
        }
      }

      final uri = Uri.parse(url);
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 20);
      try {
        final request = await client.getUrl(uri);
        final response = await request.close().timeout(
              const Duration(seconds: 30),
            );
        if (response.statusCode != HttpStatus.ok) {
          error.value = 'Gagal mengunduh PDF (${response.statusCode})';
          return;
        }

        final bytes =
            await consolidateHttpClientResponseBytes(response).timeout(
          const Duration(seconds: 40),
        );
        await file.writeAsBytes(bytes, flush: true);
        if (!isClosed) {
          pdfPath.value = file.path;
        }
      } finally {
        client.close(force: true);
      }
    } on TimeoutException {
      if (!isClosed) {
        error.value = 'Waktu memuat PDF habis. Coba buka ulang buku.';
      }
    } catch (_) {
      if (!isClosed) {
        error.value = 'Gagal memuat PDF';
      }
    }
  }

  void _rebuildVisiblePages(int pdfTotal) {
    if (_isDisposing || isClosed) return;
    _visiblePdfPages.clear();
    _pdfToVisibleIndex.clear();
    _pageTextByPdfIndex.clear();
    if (pdfTotal <= 0) {
      totalPages.value = 0;
      currentIndex.value = 0;
      return;
    }

    final skipped = <int>{};
    final pages = book.pages;
    if (pages != null && pages.isNotEmpty) {
      for (var i = 0; i < pages.length; i++) {
        final page = pages[i];
        if (page.skipped == true) {
          final rawIndex =
              page.nPage != null && page.nPage! > 0 ? page.nPage! - 1 : i;
          if (rawIndex >= 0 && rawIndex < pdfTotal) {
            skipped.add(rawIndex);
          }
        }

        final text = page.text?.trim();
        if (text != null && text.isNotEmpty) {
          final rawIndex =
              page.nPage != null && page.nPage! > 0 ? page.nPage! - 1 : i;
          if (rawIndex >= 0 && rawIndex < pdfTotal) {
            _pageTextByPdfIndex[rawIndex] = text;
          }
        }
      }
    }

    for (var i = 0; i < pdfTotal; i++) {
      if (!skipped.contains(i)) {
        _visiblePdfPages.add(i);
      }
    }

    // Fallback: if all pages were marked skipped, show all pages to avoid empty viewer.
    if (_visiblePdfPages.isEmpty) {
      for (var i = 0; i < pdfTotal; i++) {
        _visiblePdfPages.add(i);
      }
    }

    for (var i = 0; i < _visiblePdfPages.length; i++) {
      _pdfToVisibleIndex[_visiblePdfPages[i]] = i;
    }

    totalPages.value = _visiblePdfPages.length;

    if (currentIndex.value >= totalPages.value) {
      currentIndex.value = totalPages.value > 0 ? totalPages.value - 1 : 0;
    }

    if (_visiblePdfPages.isNotEmpty) {
      final firstVisible = _visiblePdfPages.first;
      if (_lastPdfPage == -1 || !_pdfToVisibleIndex.containsKey(_lastPdfPage)) {
        _lastPdfPage = firstVisible;
        currentIndex.value = 0;
        pdfController.value?.setPage(firstVisible);
      }
    }

    _speakCurrentVisibleText();
  }

  int? _nextVisiblePdf(int currentPdf, int direction) {
    if (_visiblePdfPages.isEmpty) return null;
    if (direction >= 0) {
      for (final page in _visiblePdfPages) {
        if (page > currentPdf) return page;
      }
      for (var i = _visiblePdfPages.length - 1; i >= 0; i--) {
        final page = _visiblePdfPages[i];
        if (page < currentPdf) return page;
      }
    } else {
      for (var i = _visiblePdfPages.length - 1; i >= 0; i--) {
        final page = _visiblePdfPages[i];
        if (page < currentPdf) return page;
      }
      for (final page in _visiblePdfPages) {
        if (page > currentPdf) return page;
      }
    }
    return null;
  }

  void _initTts() {
    _tts.setLanguage('id-ID');
    _tts.setPitch(1.0);
    _tts.setSpeechRate(0.5);
  }

  Future<void> _speakCurrentVisibleText() async {
    if (_isDisposing || isClosed) return;
    if (!isSoundOn.value) {
      await _stopTts();
      return;
    }

    if (_visiblePdfPages.isEmpty) {
      await _stopTts();
      return;
    }

    final visibleIdx = currentIndex.value;
    if (visibleIdx < 0 || visibleIdx >= _visiblePdfPages.length) {
      await _stopTts();
      return;
    }

    final pdfIdx = _visiblePdfPages[visibleIdx];
    final text = _pageTextByPdfIndex[pdfIdx];
    if (text == null || text.trim().isEmpty) {
      await _stopTts();
      return;
    }

    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _stopTts({bool force = false}) async {
    if (!force && (_isDisposing || isClosed)) return;
    await _tts.stop();
  }

  Future<void> _persistBookHistory() async {
    if (!_isBookInitialized || _isDisposing || isClosed) return;
    if (_isPersistingHistory) {
      _pendingPersistHistory = true;
      return;
    }

    _isPersistingHistory = true;

    try {
      do {
        _pendingPersistHistory = false;
        if (_isDisposing || isClosed) return;

        final now = DateTime.now();
        _readingTimer.stop();

        final existing = bookHistory.value;
        final total =
            totalPages.value > 0 ? totalPages.value : (book.totalPages ?? 0);
        int read = currentIndex.value + 1;
        if (total > 0 && read > total) {
          read = total;
        }

        late final BookHistoryEntity history;
        if (existing != null) {
          // UPDATE: preserve existing values that should not regress.
          final mergedRead = (existing.readPages ?? 0) > read
              ? (existing.readPages ?? 0)
              : read;
          final readingSeconds =
              _initialReadingSeconds + _readingTimer.elapsed.inSeconds;

          history = existing.copyWith(
            lastReadAt: now,
            readPages: mergedRead,
            totalReadingSeconds: readingSeconds,
          );
        } else {
          history = BookHistoryEntity(
            bookId: book.bookId,
            title: book.title,
            bookCover: book.bookCover,
            totalPages: total == 0 ? book.totalPages : total,
            readPages: read,
            isFinished: false,
            startedAt: _sessionStartedAt,
            lastReadAt: now,
            finishedAt: null,
            totalReadingSeconds: _readingTimer.elapsed.inSeconds,
            isHaveQuiz: book.isHaveQuiz,
            totalQuizes: book.totalQuizes,
            completedQuizes: null,
            category: book.category,
          );
        }

        await childrenUsecase.updateBookHistory(bookHistory: history);
        if (_isDisposing || isClosed) return;
        bookHistory.value = history;
      } while (_pendingPersistHistory && !_isDisposing && !isClosed);
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_persistBookHistory');
    } finally {
      _isPersistingHistory = false;
      if (!_readingTimer.isRunning && !_isDisposing && !isClosed) {
        _readingTimer.start();
      }
    }
  }

  Future<void> pushHistoryToFirestore() async {
    if (!_isBookInitialized) return;

    try {
      var history = bookHistory.value;
      if (history != null) {
        await childrenUsecase.updateBookHistory(
          bookHistory: history,
          pushToRemote: true,
        );
        // navController.refreshRewardBook.value++;
        EpicLog.debug(
            'pushHistoryToFirestore - Book history pushed to Firestore for bookId ${book.bookId}');
        bookHistory.value = history;
        if (history.isFinished == true &&
            history.claimedRewards != null &&
            history.claimedRewards!.isEmpty) {
          // navController.refreshRewardBook.value++;
        }
      } else {
        EpicLog.debug(
            'pushHistoryToFirestore - No book history to push for bookId ${book.bookId}');
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s,
          'pushHistoryToFirestore - Error pushing book history to Firestore');
    }
  }

  Future<void> addBookToCollection({
    required String collectionId,
    required String bookId,
  }) async {
    try {
      Get.back();
      mainController.showLoadingPage();
      await collectionUsecase
          .addBookToCollection(
            collectionId: collectionId,
            bookId: bookId,
          )
          .timeout(_collectionMutationTimeout);
      Get.back<void>();
      navController.refreshCollectionHome.value++;
      Get.snackbar(
        'Berhasil',
        'Buku ditambahkan ke koleksi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } on TimeoutException {
      Get.snackbar(
        'Timeout',
        'Proses tambah koleksi terlalu lama. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'addBookToCollection');
      Get.snackbar(
        'Gagal',
        'Tidak bisa menambah buku ke koleksi.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      mainController.hideLoadingPage();
    }
  }

  void _buildAllTextTheory() {
    final texts = book.pages
        ?.where((p) => p.skipped != true)
        .map((p) => p.text?.trim())
        .where((t) => t != null && t.isNotEmpty)
        .cast<String>()
        .toList();
    allTextTheory.value =
        texts != null && texts.isNotEmpty ? texts.join('\n') : '';
  }

  Future<void> generateQuiz({
    bool forceGenerate = false,
  }) async {
    try {
      if (book.isGenerateQuizSupported != true || book.isHaveQuiz != true) {
        EpicLog.debug('generateQuiz - skipped, quiz is not supported by book');
        return;
      }

      final quizType = book.quizType ?? 0;
      if (quizType < 1 || quizType > 3) {
        EpicLog.debug('generateQuiz - skipped, invalid quizType: $quizType');
        return;
      }

      final text = allTextTheory.value.trim();
      if (text.isEmpty) {
        EpicLog.debug('generateQuiz - skipped, theory text is empty');
        return;
      }

      if (bookHistory.value == null) {
        await _persistBookHistory();
      }

      var history = bookHistory.value;
      if (history == null) {
        EpicLog.debug('generateQuiz - failed generate, book history is null');
        return;
      }

      var quizHistory = history.quiz;
      var isQuizAlreadyGenerated =
          (quizHistory?.question?.trim().isNotEmpty ?? false);
      var isNotCompleted = (quizHistory?.answer?.trim().isEmpty ?? true);
      var totalRetry = quizHistory?.retry ?? 3;
      var firstAnswer = totalRetry == 3;
      var isCanGenerate = quizHistory == null ||
          (isNotCompleted && firstAnswer && !isQuizAlreadyGenerated);

      if (isCanGenerate || forceGenerate) {
        EpicLog.debug('generateQuiz - ready for generate');
        final previousQuestions = _extractPreviousQuestions(quizHistory);
        final generatedQuiz = await _tryGenerateQuizByQuizType(
          quizType: quizType,
          text: text,
          category: book.category,
          previousQuestions: previousQuestions,
        );
        if (generatedQuiz == null) {
          EpicLog.debug('generateQuiz - failed to generate quiz data');
          return;
        }

        final updatedHistory = history.copyWith(quiz: generatedQuiz);
        await childrenUsecase.updateBookHistory(bookHistory: updatedHistory);
        bookHistory.value = updatedHistory;
        EpicLog.debug('generateQuiz - quiz generated successfully');
      } else {
        EpicLog.debug('generateQuiz - rejected for generate');
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'generateQuiz');
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

      if (quizJson == null) {
        EpicLog.debug('_tryToGenerateMultipleChoiceQuiz - quizJson is null');
        return null;
      }

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
      final quizModel = QuizFillBlankRemoteModel.fromJson(parsed);
      // === VALIDASI ===
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

      EpicLog.debug('generateQuiz - quizJson: $quizJson');
      return quizEntity.copyWith(
        quizDataHelper: quizModel.toJson().toString(),
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_tryToGenerateGroupQuiz');
    }
    return null;
  }

  Future<void> goToQuizPage() async {
    final currentHistory = bookHistory.value;
    if (currentHistory?.quiz == null) return;
    await _stopTts(force: true);

    try {
      final result = await Get.toNamed(
        EpicRoutes.bookQuiz,
        arguments: {
          'history': currentHistory,
          'theoryText': allTextTheory.value,
          'bookQuizType': book.quizType,
          'book': book,
        },
      );
      if (result is BookHistoryEntity) {
        bookHistory.value = result;
      }
    } finally {
      await _forceLandscapeOrientation();
    }
  }

  Future<void> _forceLandscapeOrientation() async {
    const landscape = [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ];

    await SystemChrome.setPreferredOrientations(landscape);
  }
}
