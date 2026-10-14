import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_histories/state/flashcard_history_state.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:get/get.dart';

class FlashCardHomeController extends GetxController {
  final FlashCardUsecase flashCardUsecase;
  final ChildrenUsecase childrenUsecase;

  FlashCardHomeController({
    required this.flashCardUsecase,
    required this.childrenUsecase,
  });

  final flashcards = <FlashcardEntity>[].obs;
  final historyFlashcards = <FlashcardHistoryEntity>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = 'Semua'.obs;
  var isLoading = false.obs;

  final navController = Get.find<EpicNavigationController>();

  List<FlashcardEntity> get filteredRecommendations {
    if (selectedCategory.value == 'Semua') return flashcards;
    return flashcards
        .where((card) => card.category == selectedCategory.value)
        .toList();
  }

  List<FlashcardHistoryEntity> get uncompletedFlashcardHistories {
    return historyFlashcards.where((h) {
      final total = h.totalCards ?? 0;
      final cardsLen = h.cards?.length ?? 0;
      return cardsLen < total;
    }).toList();
  }

  List<FlashcardHistoryEntity> get completedFlashcardHistories {
    return historyFlashcards.where((h) {
      final total = h.totalCards ?? 0;
      final cardsLen = h.cards?.length ?? 0;
      final isFinished = h.isFinished ?? false;
      return cardsLen == total && !isFinished;
    }).toList();
  }

  List<FlashcardHistoryEntity> get filteredHistory {
    if (selectedCategory.value == 'Semua') return historyFlashcards;
    return historyFlashcards
        .where((card) => card.category == selectedCategory.value)
        .toList();
  }

  @override
  void onInit() async {
    super.onInit();
    await fetchFlashcards();

    ever(navController.selectedCategory, (value) {
      selectedCategory.value = value;
    });
  }

  Future<void> fetchFlashcards() async {
    try {
      EpicLog.debug(
          'FlashCardHomeController - Fetching flashcards and histories : $isLoading');
      isLoading.value = true;
      final fetchedHistory = await childrenUsecase.getFlashcardHistories();
      final fetchedFlashcards = await flashCardUsecase.getFlashcards();
      historyFlashcards.assignAll(fetchedHistory);
      flashcards.assignAll(fetchedFlashcards);
      sortedHistories();

      EpicLog.debug(
          'FlashCardHomeController - Finished fetching flashcards and histories : $isLoading');

      final uniqueCategories = {
        'Semua',
        ...historyFlashcards.map((e) => e.category ?? 'Lainnya'),
        ...flashcards.map((e) => e.category ?? 'Lainnya'),
      };
      EpicLog.debug(
          'FlashCardHomeController - Unique categories extracted: $uniqueCategories');

      categories.assignAll(uniqueCategories.toList());
      selectedCategory.value = categories.first;
    } catch (ex, s) {
      EpicLog.exception(ex, s, 'Failed to fetch flashcards');
    } finally {
      isLoading.value = false;
      EpicLog.debug(
          "homeController - Finished fetching flashcards : $isLoading");
    }
  }

  void goToFlashcardRead(FlashcardEntity flashcard) async {
    await Get.toNamed(
      EpicRoutes.flashCardRead,
      arguments: flashcard,
    );
    var histories = await childrenUsecase.getFlashcardHistories(
      refreshLocal: true,
    );
    historyFlashcards.clear();
    historyFlashcards.assignAll(histories);
    sortedHistories();
  }

  void goToFlashcardReadFromHistory(
    FlashcardHistoryEntity history,
  ) async {
    final selectedFlashcard = flashcards
        .where((element) => element.flashcardId == history.flashcardId)
        .firstOrNull;

    await Get.toNamed(
      EpicRoutes.flashCardRead,
      arguments: selectedFlashcard,
    );

    final histories = await childrenUsecase.getFlashcardHistories(
      refreshLocal: true,
    );

    historyFlashcards
      ..clear()
      ..assignAll(histories);

    sortedHistories();
  }

  void goToFlashcardHistories(FlashcardHistoryState state) {
    Get.toNamed(
      EpicRoutes.flashcardHistories,
      arguments: state,
    );
  }

  void sortedHistories() {
    historyFlashcards.sort((a, b) =>
        b.lastReadAt?.compareTo(
            a.lastReadAt ?? DateTime.fromMillisecondsSinceEpoch(0)) ??
        0);
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}
