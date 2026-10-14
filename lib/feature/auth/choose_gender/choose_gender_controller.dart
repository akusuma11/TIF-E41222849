import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/domain/entities/children_entity.dart';
import 'package:get/get.dart';

class ChooseGenderController extends GetxController{

  var selectedGender = ''.obs;

  void goToDateBirth() {
    if (selectedGender.isEmpty) {
      EpicSnackBar.showWarningSnackBar("Warning", "Gender belum dipilih!");
      return;
    }

    var children = ChildrenEntity(gender: selectedGender.value);
    EpicLog.info("Navigating to DateBirthPage with: $children");

    Get.toNamed(
      EpicRoutes.chooseDateBirth,
      arguments: children,
    );
  }

}