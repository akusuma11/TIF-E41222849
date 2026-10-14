import 'package:epic_story_app/data/modules/collection_module.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/favorites/presentation/create_collection/create_collection_controller.dart';
import 'package:get/get.dart';

class CreateCollectionBinding extends Bindings {
  @override
  void dependencies() {
    CollectionModule();
    Get.lazyPut<CreateCollectionController>(
      () => CreateCollectionController(
        collectionUsecase: Get.find<CollectionUsecase>(),
      ),
    );
  }
}
