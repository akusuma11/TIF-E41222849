import 'package:epic_story_app/feature/auth/choose_gender/choose_gender_controller.dart';
import 'package:get/get.dart';

class ChooseGenderBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => ChooseGenderController());
  }
}