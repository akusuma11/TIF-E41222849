import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/utils/splash_screen/splash_screen_controller.dart';
import 'package:get/get.dart';

class SplashScreenBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();

    Get.lazyPut(
      () => SplashScreenController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
      ),
    );
  }
}
