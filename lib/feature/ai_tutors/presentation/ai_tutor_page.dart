import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/feature/ai_tutors/presentation/ai_tutor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiTutorPage extends StatelessWidget {
  const AiTutorPage({super.key});

  @override
  Widget build(BuildContext context) {

    final AiTutorController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.purple.withOpacity(0.4),
      body: Center(
        child: Text(
          "AI Tutor Home",
          style: EpicSize.headlineLarge,
        ),
      ),
    );
  }
}
