import 'package:epic_story_app/data/modules/book_module.dart';
import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/data/modules/flashcard_module.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:epic_story_app/feature/ai_tutors/presentation/ai_tutor_controller.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:epic_story_app/feature/favorites/presentation/favorite_home/favorite_home_controller.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_home/flashcard_home_controller.dart';
import 'package:epic_story_app/feature/home/home_controller.dart';
import 'package:epic_story_app/feature/profiles/presentation/profile_controller.dart';
import 'package:epic_story_app/feature/rewards/reward_home/reward_home_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:get/get.dart';

class EpicNavigationBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    CollectionModule();
    BookModule();
    FlashCardModule();

    Get.lazyPut<HomeController>(
      () => HomeController(
        collectionUsecase: Get.find<CollectionUsecase>(),
        childrenUsecase: Get.find<ChildrenUsecase>(),
        flashCardUsecase: Get.find<FlashCardUsecase>(),
        bookUsecase: Get.find<BookUsecase>(),
      ),
    );

    Get.lazyPut(() => AiTutorController());
    Get.lazyPut(() => BookHomeController(
      childrenUsecase: Get.find<ChildrenUsecase>(),
          bookUsecase: Get.find<BookUsecase>(),
          collectionUsecase: Get.find<CollectionUsecase>(),
        ));
    Get.lazyPut(() => FlashCardHomeController(
          flashCardUsecase: Get.find<FlashCardUsecase>(),
          childrenUsecase: Get.find<ChildrenUsecase>(),
        ));
    Get.lazyPut(() => FavoriteHomeController(
          collectionUsecase: Get.find<CollectionUsecase>(),
    ));
    Get.lazyPut(() => ProfileController(
          childrenUsecase: Get.find<ChildrenUsecase>(),
        ));

    Get.lazyPut<RewardHomeController>(
      () => RewardHomeController(
        collectionUsecase: Get.find<CollectionUsecase>(),
        childrenUsecase: Get.find<ChildrenUsecase>(),
        flashCardUsecase: Get.find<FlashCardUsecase>(),
        bookUsecase: Get.find<BookUsecase>(),
      ),
    );

    Get.lazyPut(() => EpicNavigationController());
  }
}
