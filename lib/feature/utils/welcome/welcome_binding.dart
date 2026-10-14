import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/utils/welcome/welcome_controller.dart';
import 'package:get/get.dart';

class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();

    Get.lazyPut(() => WelcomeController(
      childrenUsecase: Get.find<ChildrenUsecase>(),
    ));
  }
}
