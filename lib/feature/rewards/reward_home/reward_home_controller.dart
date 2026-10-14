import 'dart:async';

import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:get/get.dart';

class RewardHomeController extends GetxController {
  final CollectionUsecase collectionUsecase;
  final ChildrenUsecase childrenUsecase;
  final FlashCardUsecase flashCardUsecase;
  final BookUsecase bookUsecase;

  RewardHomeController({
    required this.collectionUsecase,
    required this.childrenUsecase,
    required this.flashCardUsecase,
    required this.bookUsecase,
  });

  final navController = Get.find<EpicNavigationController>();
  final mainController = Get.find<MainController>();

  var isBook = true.obs;
  var isLoading = false.obs;

  final flashcards = <FlashcardEntity>[].obs;
  final historyFlashcards = <FlashcardHistoryEntity>[].obs;

  final books = <BookEntity>[].obs;
  final historyBooks = <BookHistoryEntity>[].obs;

  List<BookEntity> _allBooks = [];
  List<FlashcardEntity> _allFlashcards = [];

  StreamSubscription<List<BookHistoryEntity>>? _bookHistorySub;
  StreamSubscription<List<FlashcardHistoryEntity>>? _flashcardHistorySub;

  @override
  void onInit() async {
    super.onInit();
    await _fetchBaseData();
    _subscribeToHistories();
  }

  @override
  void onClose() {
    _bookHistorySub?.cancel();
    _flashcardHistorySub?.cancel();
    super.onClose();
  }

  Future<void> _fetchBaseData() async {
    try {
      isLoading.value = true;
      final fetchedBooks = await bookUsecase.getBooks();
      final fetchedFlashcards = await flashCardUsecase.getFlashcards();
      _allBooks = fetchedBooks.books;
      _allFlashcards = fetchedFlashcards;
    } catch (ex, s) {
      EpicLog.exception(ex, s, 'Error fetching base data');
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToHistories() {
    _bookHistorySub = childrenUsecase.streamBookHistories().listen(
      (histories) {
        EpicLog.debug('streamBookHistories update: ${histories.length}');
        final finished = histories.where((e) => e.isFinished == true);
        historyBooks.assignAll(finished);
        books.assignAll(
          _allBooks.where(
            (book) => finished.any((h) => h.bookId == book.bookId),
          ),
        );
      },
      onError: (ex, s) {
        EpicLog.exception(ex, s, 'streamBookHistories error');
      },
    );

    _flashcardHistorySub = childrenUsecase.streamFlashcardHistories().listen(
      (histories) {
        EpicLog.debug('streamFlashcardHistories update: ${histories.length}');
        final finished = histories.where((e) => e.isFinished == true);
        historyFlashcards.assignAll(finished);
        flashcards.assignAll(
          _allFlashcards.where(
            (fc) => finished.any((h) => h.flashcardId == fc.flashcardId),
          ),
        );
        sortedHistories();
      },
      onError: (ex, s) {
        EpicLog.exception(ex, s, 'streamFlashcardHistories error');
      },
    );
  }

  void sortedHistories() {
    historyFlashcards.sort((a, b) =>
        b.lastReadAt?.compareTo(
            a.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0)) ??
        0);
  }

  FlashcardHistoryEntity? historyFor(String? flashcardId) {
    if (flashcardId == null) return null;
    return historyFlashcards.firstWhereOrNull(
      (h) => h.flashcardId == flashcardId,
    );
  }

  BookHistoryEntity? historyForBook(String? bookId) {
    if (bookId == null) return null;
    return historyBooks.firstWhereOrNull(
      (h) => h.bookId == bookId,
    );
  }

  void openRewardClaim(FlashcardEntity flashcard) async {
    bool result = await Get.toNamed(
      EpicRoutes.flashcardReward,
      arguments: flashcard,
    );

    if (result == true) {
      // history update will arrive automatically via stream
    }
  }

  void goToFlashcardRead(FlashcardEntity flashcard) async {
    await Get.toNamed(
      EpicRoutes.flashCardRead,
      arguments: flashcard,
    );
  }

  void goToBookRead(BookEntity book) async {
    await Get.toNamed(
      EpicRoutes.bookRead,
      arguments: book,
    );
    // history update will arrive automatically via stream
  }

  void openBookRewardClaim(BookEntity book) async {
    await Get.toNamed(
      EpicRoutes.bookReward,
      arguments: book,
    );
    // history update will arrive automatically via stream
  }

  Future<void> refreshActiveTab() async {
    // base data (books/flashcards) can be re-fetched manually if needed;
    // history is always up-to-date via stream
    await _fetchBaseData();
  }
}
