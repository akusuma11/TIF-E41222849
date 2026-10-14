import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:get/get.dart';
import '../../../core/utils/epic_log.dart';

class WelcomeController extends GetxController {
  final ChildrenUsecase childrenUsecase;

  final mainController = Get.find<MainController>();

  WelcomeController({required this.childrenUsecase});

  void signInWithGoogle() async {
    try {
      EpicLog.debug("Starting Google Sign-In process");
      final signInFire = await mainController.loginGoogle();
      if (signInFire) {
        mainController.showLoadingPage();
      }
      final result = await childrenUsecase.isEmptyProfileData();
      if (signInFire) {
        if (result == true) {
          await Get.offAllNamed(EpicRoutes.navigation);
        } else {
          await Get.offAllNamed(EpicRoutes.navigation);
        }
        // Wait until navigation completes, then hide the loading page
        mainController.hideLoadingPage();
      }
    } catch (ex, s) {
      mainController.hideLoadingPage();
      EpicLog.exception(ex, s, this, 'signInWithGoogle');
    }
  }
}
