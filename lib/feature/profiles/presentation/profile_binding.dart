import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/profiles/presentation/profile_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings{
  @override
  void dependencies() {
    ChildrenModule();

    Get.lazyPut(() => ProfileController(
      childrenUsecase: Get.find<ChildrenUsecase>(),
    ));
  }
}