import 'package:epic_story_app/feature/utils/test_tts/test_tts_controller.dart';
import 'package:get/get.dart';

class TestTtsBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => TestTtsController());
  }

}