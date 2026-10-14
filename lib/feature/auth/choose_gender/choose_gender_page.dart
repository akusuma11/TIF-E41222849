import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/core/constants/ui/app_size.dart';
import 'package:epic_story_app/core/widgets/default_ui/epic_button.dart';
import 'package:epic_story_app/feature/auth/choose_gender/choose_gender_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseGenderPage extends StatelessWidget {
  const ChooseGenderPage({super.key});

  @override
  Widget build(BuildContext context) {

    final ChooseGenderController controller = Get.find();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Pilih Jenis Kelamin",
                style: EpicSize.headlineLarge,
              ),
              AppSize.spacing2XLHeight(),
              EpicButton(
                text: "Laki-Laki",
                backgroundColor: Colors.lightBlue,
                width: EpicSize.screenWidth * 0.8,
                height: 100,
                prefixIcon: const Icon(
                  Icons.male,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.selectedGender.value = 'Laki-Laki';
                  controller.goToDateBirth();
                },
              ),
              AppSize.spacingLHeight(),
              EpicButton(
                text: "Perempuan",
                backgroundColor: Colors.pink,
                fontWeight: FontWeight.bold,
                height: 100,
                width: EpicSize.screenWidth * 0.8,
                prefixIcon: const Icon(
                  Icons.female,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.selectedGender.value = 'Perempuan';
                  controller.goToDateBirth();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
