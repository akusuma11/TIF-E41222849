import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/core/constants/ui/app_size.dart';
import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/widgets/default_ui/epic_button.dart';
import 'package:epic_story_app/core/widgets/default_ui/epic_date_picker.dart';
import 'package:epic_story_app/feature/auth/choose_date_birth/choose_date_birth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChooseDateBirthPage extends StatelessWidget {
  const ChooseDateBirthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChooseDateBirthController controller = Get.find();

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
                      "Masukan tangal lahir kamu",
                      style: EpicSize.headlineLarge,
                    ),
                    AppSize.spacing2XLHeight(),
                    Obx(() {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: EpicDatePicker(
                          label: 'Tanggal Lahir',
                          hint: 'Pilih tanggal lahir Kamu',
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2003),
                          lastDate: controller.selectedDate.value,
                          onDateSelected: (date) {
                            controller.selectedDate.value =
                                date ?? DateTime.now();
                          },
                          dateFormat: 'dd MMM yyyy',
                          errorText: null,
                          clearable: true,
                        ),
                      );
                    })
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
                          text: "Next",
                          onPressed: () {
                            controller.goToGradeClass();
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
