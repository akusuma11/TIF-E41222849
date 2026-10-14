import 'package:epic_story_app/domain/entities/quiz/quiz_choice_entity.dart';
import 'package:get/get.dart';

class MultipleChoiceController extends GetxController {
  late QuizChoiceEntity quizChoice;

  @override
  void onInit() {
    super.onInit();
    quizChoice = Get.arguments as QuizChoiceEntity;
  }
}