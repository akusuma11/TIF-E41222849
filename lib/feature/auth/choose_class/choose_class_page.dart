import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/core/constants/ui/app_size.dart';
import 'package:epic_story_app/core/widgets/default_ui/epic_button.dart';
import 'package:epic_story_app/feature/auth/choose_class/choose_class_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseClassPage extends StatelessWidget {
  const ChooseClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChooseClassController controller = Get.find();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            height: EpicSize.screenHeight * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    AppSize.spacing7XLHeight(),
                    Text(
                      "Pilih Kelas Kamu",
                      style: EpicSize.headlineLarge,
                    ),
                    AppSize.spacing2XLHeight(),
                    Obx(() => EpicButton(
                          text: "Kelas 1",
                          width: EpicSize.screenWidth * 0.75,
                          height: 50,
                          backgroundColor: controller.selectedClass.value == 1
                              ? Colors.red
                              : Colors.red.withOpacity(0.3),
                          onPressed: () {
                            controller.selectClass(1);
                          },
                        )),
                    AppSize.spacingMHeight(),
                    Obx(() => EpicButton(
                          text: "Kelas 2",
                          width: EpicSize.screenWidth * 0.75,
                          height: 50,
                          backgroundColor: controller.selectedClass.value == 2
                              ? Colors.teal
                              : Colors.teal.withOpacity(0.3),
                          onPressed: () {
                            controller.selectClass(2);
                          },
                        )),
                    AppSize.spacingMHeight(),
                    Obx(() => EpicButton(
                          text: "Kelas 3",
                          width: EpicSize.screenWidth * 0.75,
                          height: 50,
                          backgroundColor: controller.selectedClass.value == 3
                              ? Colors.orange
                              : Colors.orange.withOpacity(0.3),
                          onPressed: () {
                            controller.selectClass(3);
                          },
                        )),
                    AppSize.spacingMHeight(),
                    Obx(() => EpicButton(
                          text: "Kelas 4",
                          width: EpicSize.screenWidth * 0.75,
                          height: 50,
                          backgroundColor: controller.selectedClass.value == 4
                              ? Colors.green
                              : Colors.green.withOpacity(0.3),
                          onPressed: () {
                            controller.selectClass(4);
                          },
                        )),
                    AppSize.spacingMHeight(),
                    Obx(() => EpicButton(
                          text: "Kelas 5",
                          width: EpicSize.screenWidth * 0.75,
                          height: 50,
                          backgroundColor: controller.selectedClass.value == 5
                              ? Colors.blueAccent
                              : Colors.blueAccent.withOpacity(0.3),
                          onPressed: () {
                            controller.selectClass(5);
                          },
                        )),
                    AppSize.spacingMHeight(),
                    Obx(() => EpicButton(
                          text: "Kelas 6",
                          width: EpicSize.screenWidth * 0.75,
                          height: 50,
                          backgroundColor: controller.selectedClass.value == 6
                              ? Colors.purple
                              : Colors.purple.withOpacity(0.3),
                          onPressed: () {
                            controller.selectClass(6);
                          },
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: EpicButton(
                          text: "Previous",
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: EpicButton(
                          text: "Save",
                          onPressed: () {
                            controller.save();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
