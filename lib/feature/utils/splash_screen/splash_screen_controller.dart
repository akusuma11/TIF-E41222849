import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  final ChildrenUsecase childrenUsecase;

  SplashScreenController({
    required this.childrenUsecase,
  });

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(seconds: 2));
    bool isLogged = await childrenUsecase.isLogged();
    if (isLogged) {
      try {
        await childrenUsecase
            .syncChildrenData()
            .timeout(const Duration(seconds: 6));
      } catch (ex, s) {
        EpicLog.exception(ex, s, this, 'onInit.syncChildrenData');
      }
      if (await childrenUsecase.isEmptyProfileData() == true) {
        Get.offAllNamed(EpicRoutes.navigation);
      } else {
        Get.offAllNamed(EpicRoutes.navigation);
      }
    } else {
      Get.offAllNamed(EpicRoutes.welcome);
    }
  }
}
