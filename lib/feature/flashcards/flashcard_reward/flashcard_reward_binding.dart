import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_reward/flashcard_reward_controller.dart';
import 'package:get/get.dart';

class FlashcardRewardBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    Get.lazyPut<FlashcardRewardController>(
      () => FlashcardRewardController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
      ),
    );
  }
}
