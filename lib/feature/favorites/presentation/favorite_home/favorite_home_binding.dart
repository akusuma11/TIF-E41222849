import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/favorites/presentation/favorite_home/favorite_home_controller.dart';
import 'package:get/get.dart';

class FavoriteHomeBinding extends Bindings {
  @override
  void dependencies() {
    CollectionModule();
    Get.lazyPut(() => FavoriteHomeController(
          collectionUsecase: Get.find<CollectionUsecase>(),
    ));
  }
}
