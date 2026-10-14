import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_result/flashcard_result_controller.dart';
import 'package:get/get.dart';

class FlashCardResultBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    Get.lazyPut(() => FlashCardResultController(
      childrenUsecase: Get.find<ChildrenUsecase>(),
    ));
  }
}
