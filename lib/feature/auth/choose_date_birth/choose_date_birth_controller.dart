import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/entities/children_entity.dart';
import 'package:get/get.dart';
class ChooseDateBirthController extends GetxController {
  var selectedDate = DateTime.now().obs;
  late ChildrenEntity argument;

  @override
  void onInit() {
    super.onInit();

    argument = Get.arguments as ChildrenEntity;
    ever(selectedDate, (date) {
      EpicLog.info("Selected date changed: $date");
    });
  }

  void goToGradeClass() {
    var children = argument.copyWith(
      dateBirth: selectedDate.value,
    );
    Get.toNamed(
      EpicRoutes.chooseClass,
      arguments: children,
    );
  }
}
