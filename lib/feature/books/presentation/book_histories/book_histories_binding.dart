import 'package:get/get.dart';

import 'book_histories_controller.dart';

class BookHistoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookHistoriesController>(
      () => BookHistoriesController(),
    );
  }
}