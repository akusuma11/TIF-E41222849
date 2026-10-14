import 'package:get/get.dart';

import '../../../../data/modules/children_module.dart';
import '../../../../domain/usecases/children_usecase.dart';

import 'book_reward_controller.dart';

class BookRewardBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    Get.lazyPut<BookRewardController>(
      () => BookRewardController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
      ),
    );
  }
}
