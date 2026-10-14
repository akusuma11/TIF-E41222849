import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/domain/entities/children_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final ChildrenUsecase childrenUsecase;

  ProfileController({
    required this.childrenUsecase,
  });

  final mainController = Get.find<MainController>();

  var childrenData = Rx<ChildrenEntity?>(null);

  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      childrenData.value = await childrenUsecase.getCurrentChildren();
    });
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: "Konfirmasi",
      middleText: "Yakin mau logout?",
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await mainController.studentLogout();
        Get.offAllNamed(EpicRoutes.welcome);
      },
    );
  }
}
