import 'package:epic_story_app/data/modules/book_module.dart';
import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/data/modules/flashcard_module.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    CollectionModule();
    FlashCardModule();
    BookModule();
    Get.lazyPut<HomeController>(
      () => HomeController(
        collectionUsecase: Get.find<CollectionUsecase>(),
        childrenUsecase: Get.find<ChildrenUsecase>(),
        flashCardUsecase: Get.find<FlashCardUsecase>(),
        bookUsecase: Get.find<BookUsecase>(),
      ),
    );
  }
}
