import 'package:get/get.dart';

import 'flashcard_histories_controller.dart';

class FlashcardHistoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlashcardHistoriesController>(
      () => FlashcardHistoriesController(),
    );
  }
}