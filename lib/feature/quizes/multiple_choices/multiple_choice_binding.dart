import 'package:get/get.dart';
import 'multiple_choice_controller.dart';

class MultipleChoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MultipleChoiceController>(() => MultipleChoiceController());
  }
}