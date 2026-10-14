import 'package:epic_story_app/feature/flashcards/flashcard_histories/state/flashcard_history_state.dart';
import 'package:get/get.dart';

import '../../../domain/entities/flashcards/flashcard_history_entity.dart';
import '../flashcard_home/flashcard_home_controller.dart';

class FlashcardHistoriesController extends GetxController {
  late FlashcardHistoryState selectedState;
  final flashcardHomeController = Get.find<FlashCardHomeController>();

  var histories = <FlashcardHistoryEntity>[].obs;

  void openFromHistory(FlashcardHistoryEntity history) {
    flashcardHomeController.goToFlashcardReadFromHistory(history);
  }

  var title = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedState = Get.arguments;
    switch (selectedState) {
      case FlashcardHistoryState.allHistories:
        histories.value = flashcardHomeController.historyFlashcards;
        title.value = 'Semua Riwayat';
        break;
      case FlashcardHistoryState.learnHistories:
        histories.value = flashcardHomeController.uncompletedFlashcardHistories;
        title.value = 'Flashcard yang belum kamu selesaikan';
        break;
      case FlashcardHistoryState.quizHistories:
        histories.value = flashcardHomeController.completedFlashcardHistories;
        title.value = 'Kuis yang belum kamu kerjakan';
        break;
    }
  }
}
