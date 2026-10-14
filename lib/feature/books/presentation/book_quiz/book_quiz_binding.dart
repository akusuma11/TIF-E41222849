import 'package:get/get.dart';
import 'package:epic_story_app/data/modules/children_module.dart';
import 'package:epic_story_app/data/modules/quiz_module.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/quiz_usecase.dart';

import 'book_quiz_controller.dart';

class BookQuizBinding extends Bindings {
  @override
  void dependencies() {
    ChildrenModule();
    QuizModule();
    Get.lazyPut(
      () => BookQuizController(
        childrenUsecase: Get.find<ChildrenUsecase>(),
        quizUsecase: Get.find<QuizUsecase>(),
      ),
    );
  }
}
