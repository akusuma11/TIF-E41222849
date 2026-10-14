import 'package:epic_story_app/feature/ai_tutors/presentation/ai_tutor_controller.dart';
import 'package:get/get.dart';

class AiTutorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiTutorController());
  }
}
