import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/data/modules/flashcard_module.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:get/get.dart';

import 'detail_collection_flashcard_controller.dart';

class DetailCollectionFlashcardBidings extends Bindings {
  @override
  void dependencies() {
    CollectionModule();
    FlashCardModule();
    Get.lazyPut(() => DetailCollectionFlashcardController(
          collectionUsecase: Get.find<CollectionUsecase>(),
          flashCardUsecase: Get.find<FlashCardUsecase>(),
        ));
  }
}
