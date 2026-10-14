import 'package:epic_story_app/feature/auth/choose_date_birth/choose_date_birth_controller.dart';
import 'package:get/get.dart';

class ChooseDateBirthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChooseDateBirthController());
  }
}
