import 'package:epic_story_app/data/modules/book_module.dart';
import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:get/get.dart';

class BookHomeBinding extends Bindings {
  @override
  void dependencies() {
    BookModule();
    CollectionModule();
    CollectionModule();
    Get.lazyPut(() => BookHomeController(
          collectionUsecase: Get.find<CollectionUsecase>(),
          bookUsecase: Get.find<BookUsecase>(),
          childrenUsecase: Get.find<ChildrenUsecase>(),
        ));
  }
}
