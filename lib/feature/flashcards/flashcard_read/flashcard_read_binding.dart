import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/data/modules/quiz_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/quiz_usecase.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_read_controller.dart';
import 'package:get/get.dart';

class FlashCardReadBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    CollectionModule();
    QuizModule();
    Get.lazyPut<FlashcardReadController>(
      () => FlashcardReadController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
        collectionUsecase: Get.find<CollectionUsecase>(),
        quizUsecase: Get.find<QuizUsecase>(),
      ),
    );
  }
}
