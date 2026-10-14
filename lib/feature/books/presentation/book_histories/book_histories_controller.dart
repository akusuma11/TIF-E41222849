import 'package:epic_story_app/feature/books/presentation/book_histories/state/book_histories_state.dart';
import 'package:get/get.dart';

import '../../../../domain/entities/book_histories_entity.dart';
import '../book_home/book_home_controller.dart';

class BookHistoriesController extends GetxController {
  final bookHomeController = Get.find<BookHomeController>();

  late BookHistoriesState selectedState;
  var histories = <BookHistoryEntity>[].obs;

  void openFromHistory(BookHistoryEntity history) {
    bookHomeController.gotoBookReadFromHistory(history);
  }

  var title = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedState = Get.arguments;
    switch (selectedState) {
      case BookHistoriesState.allHistories:
        histories.value = bookHomeController.histories;
        title.value = 'Semua Riwayat';
        break;
      case BookHistoriesState.learnHistories:
        histories.value = bookHomeController.uncompletedHistories;
        title.value = 'Buku yang belum kamu selesaikan';
        break;
      case BookHistoriesState.quizHistories:
        histories.value = bookHomeController.completedHistories;
        title.value = 'Kuis yang belum kamu kerjakan';
        break;
    }
  }
}
