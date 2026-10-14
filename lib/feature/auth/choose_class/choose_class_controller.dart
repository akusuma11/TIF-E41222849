import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/entities/children_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:get/get.dart';

class ChooseClassController extends GetxController {
  var selectedClass = 0.obs;
  late ChildrenEntity argument;

  final ChildrenUsecase childrenUsecase;

  ChooseClassController({
    required this.childrenUsecase,
  });

  @override
  void onInit() {
    super.onInit();

    argument = Get.arguments;
    ever(selectedClass, (classValue) {
      EpicLog.info("Selected class changed: $classValue");
    });
  }

  void save() async {
    if (selectedClass.value == 0) {
      Get.snackbar('Error', 'Pilih kelas terlebih dahulu');
      return;
    }

    var currentChildren = await childrenUsecase.getCurrentChildren();
    if (currentChildren == null) return;
    var newChildren = currentChildren.copyWith(
      gender: argument.gender,
      dateBirth: argument.dateBirth,
      gradeClass: selectedClass.value,
      updatedAt: DateTime.now(),
    );
    EpicLog.info("gender : ${newChildren.gender}");
    EpicLog.info("date birth : ${newChildren.dateBirth}");
    EpicLog.info("grade class : ${newChildren.gradeClass}");
    await childrenUsecase.addOrUpdateChildrenLocal(children: newChildren);
    await childrenUsecase.addOrUpdateChildrenRemote(children: newChildren);
    Get.toNamed(EpicRoutes.navigation);
  }

  void selectClass(int code) {
    selectedClass.value = code;
  }
}
