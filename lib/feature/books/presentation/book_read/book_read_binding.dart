import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/data/modules/quiz_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/quiz_usecase.dart';
import 'package:epic_story_app/feature/books/presentation/book_read/book_read_controller.dart';
import 'package:get/get.dart';

class BookReadBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    QuizModule();
    CollectionModule();
    Get.lazyPut<BookReadController>(
      () => BookReadController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
        quizUsecase: Get.find<QuizUsecase>(),
        collectionUsecase: Get.find<CollectionUsecase>(),
      ),
    );
  }
}
