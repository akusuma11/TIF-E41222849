import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/books/presentation/book_histories/state/book_histories_state.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:get/get.dart';

class BookHomeController extends GetxController {
  final BookUsecase bookUsecase;
  final CollectionUsecase collectionUsecase;
  final ChildrenUsecase childrenUsecase;

  final MainController mainController = Get.find<MainController>();
  var histories = <BookHistoryEntity>[].obs;

  BookHomeController({
    required this.bookUsecase,
    required this.collectionUsecase,
    required this.childrenUsecase,
  });

  final categories = <String>[].obs;
  final selectedCategory = 'Semua'.obs;

  var isLoading = false.obs;
  final RxList<BookEntity> books = <BookEntity>[].obs;

  final navController = Get.find<EpicNavigationController>();

  List<BookEntity> get filteredBooks {
    if (selectedCategory.value == 'Semua') return books;
    return books
        .where((book) => (book.category ?? 'Lainnya') == selectedCategory.value)
        .toList();
  }

  List<BookHistoryEntity> get uncompletedHistories {
    return histories.where((h) {
      final total = (h.totalPages ?? 0)-2;
      final pagesRead = h.readPages ?? 0;
      return pagesRead < total;
    }).toList();
  }

  List<BookHistoryEntity> get completedHistories {
    return histories.where((h) {
      final total = (h.totalPages ?? 0)-2;
      final pagesRead = h.readPages ?? 0;
      final isFinished = h.isFinished ?? false;
      return pagesRead == total && !isFinished;
    }).toList();
  }

  List<BookHistoryEntity> get filteredHistory {
    if (selectedCategory.value == 'Semua') return histories;
    return histories
        .where((history) =>
            (history.category ?? 'Lainnya') == selectedCategory.value)
        .toList();
  }

  @override
  void onInit() async {
    super.onInit();
    ever(navController.selectedCategory, (value) {
      selectedCategory.value = value.isEmpty ? 'Semua' : value;
    });
    // await loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      isLoading.value = true;
      final bookData = await bookUsecase.getBooks(limit: 20);
      final bookHistories = await childrenUsecase.getBookHistories();
      books.clear();
      books.addAll(bookData.books);
      histories.clear();
      histories.addAll(bookHistories);
      sortedHistories();
      _buildCategories();
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'loadBooks');
    } finally {
      isLoading.value = false;
      EpicLog.debug("homeController - Finished fetching books : $isLoading");
    }
  }

  void sortedHistories() {
    histories.sort((a, b) =>
        b.lastReadAt?.compareTo(
            a.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0)) ??
        0);
  }

  void _buildCategories() {
    final uniqueCategories = {
      'Semua',
      ...books.map((e) => e.category ?? 'Lainnya'),
    };

    categories.assignAll(uniqueCategories.toList());

    if (categories.isNotEmpty) {
      final current = navController.selectedCategory.value;
      selectedCategory.value = current.isNotEmpty ? current : categories.first;
    }
  }

  Future<void> addBookToCollection({
    required String collectionId,
    required String bookId,
  }) async {
    try {
      mainController.showLoadingPage();
      await collectionUsecase.addBookToCollection(
        collectionId: collectionId,
        bookId: bookId,
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'addBookToCollection');
    } finally {
      mainController.hideLoadingPage();
    }
  }

  Future<void> reactBook({
    required String bookId,
    required String emoticon,
    bool isIncrement = true,
  }) async {
    try {
      mainController.showLoadingPage();
      await mainController.childrenUsecase.reactBook(
        bookId: bookId,
        emoticon: emoticon,
        isIncrement: isIncrement,
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'reactBook');
    } finally {
      mainController.hideLoadingPage();
    }
  }

  void goToBookRead(BookEntity book) async {
    await Get.toNamed(
      EpicRoutes.bookRead,
      arguments: book,
    );
    final updatedHistories = await childrenUsecase.getBookHistories(
      refreshLocal: true,
    );
    histories.clear();
    histories.addAll(updatedHistories);
    sortedHistories();
    _buildCategories();
  }

  void gotoBookReadFromHistory(BookHistoryEntity history) async {
    final book = books.firstWhereOrNull((b) => b.bookId == history.bookId);
    if (book == null) {
      EpicLog.debug(
          'Book with ID ${history.bookId} not found for history ${history.bookId}');
      return;
    }
    await Get.toNamed(
      EpicRoutes.bookRead,
      arguments: book,
    );
    final updatedHistories = await childrenUsecase.getBookHistories(
      refreshLocal: true,
    );
    histories.clear();
    histories.addAll(updatedHistories);
    sortedHistories();
    _buildCategories();
  }

  void goToBookHistories(BookHistoriesState state) {
    Get.toNamed(EpicRoutes.bookHistories, arguments: state);
  }
}
