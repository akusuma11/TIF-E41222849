import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/auth/choose_class/choose_class_controller.dart';
import 'package:get/get.dart';

class ChooseClassBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();

    Get.lazyPut(
      () => ChooseClassController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
      ),
    );
  }
}
