import 'package:epic_story_app/data/modules/book_module.dart';
import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:get/get.dart';

import 'detail_collection_controller.dart';

class DetailCollectionBinding extends Bindings {
  @override
  void dependencies() {
    CollectionModule();
    BookModule();
    Get.lazyPut<DetailCollectionController>(
      () => DetailCollectionController(
        collectionUsecase: Get.find<CollectionUsecase>(),
        bookUsecase: Get.find<BookUsecase>(),
      ),
    );
  }
}
