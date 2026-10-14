import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/flashcard_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:get/get.dart';

import 'flashcard_home_controller.dart';

class FlashCardHomeBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    FlashCardModule();
    Get.lazyPut<FlashCardHomeController>(
      () => FlashCardHomeController(
        flashCardUsecase: Get.find<FlashCardUsecase>(),
        childrenUsecase: Get.find<ChildrenUsecase>(),
      ),
    );
  }
}
