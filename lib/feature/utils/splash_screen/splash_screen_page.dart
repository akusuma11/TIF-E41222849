import 'package:epic_story_app/feature/utils/splash_screen/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {

    final SplashScreenController controller = Get.find();

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "This is Splash Screen",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
