import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_card_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:get/get.dart';

class FlashCardResultController extends GetxController {
  late FlashcardEntity flashcard;
  final correctCount = 0.obs;
  final wrongCount = 0.obs;
  final totalQuiz = 0.obs;
  final completedQuiz = 0.obs;
  final totalCards = 0.obs;
  var isRewardClaimed = false.obs;

  final ChildrenUsecase childrenUsecase;

  FlashCardResultController({
    required this.childrenUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    _initArgs();
  }

  List<FlashcardCardEntity> get cards => flashcard.cards ?? [];
  var flashcardHistory = Rxn(FlashcardHistoryEntity());

  void _initArgs() async {
    flashcard = const FlashcardEntity(title: 'Flashcard Title');

    final args = Get.arguments;
    if (args is FlashcardEntity) {
      final argFlashcard = args;
      flashcard = argFlashcard;
      flashcardHistory.value = await childrenUsecase.getFlashcardHistoryById(
        flashcard.flashcardId ?? '',
      );

      correctCount.value = flashcardHistory.value?.cards
              ?.where((card) => card.completedQuiz == true)
              .length ??
          0;
      wrongCount.value = flashcardHistory.value?.cards
              ?.where((card) => card.completedQuiz == false)
              .length ??
          0;
      totalQuiz.value =
          flashcard.cards?.where((card) => card.quizType != null).length ?? 0;
      totalCards.value = (flashcard.cards?.length ?? 0) - totalQuiz.value;
    }

    _updateClaimedFlag();
    EpicLog.debug(
        'Flashcard history loaded with claimed rewards: ${flashcardHistory.value?.claimedRewards}');
    EpicLog.debug(
        'Initialized FlashCardResultController with flashcard: ${flashcard.title}, total cards: ${flashcard.cards?.length ?? 0}, correct: ${correctCount.value}, wrong: ${wrongCount.value}');
  }

  void goToClaimReward() async {
    if (isRewardClaimed.value) {
      EpicSnackBar.showSuccessSnackBar(
        "Info",
        "Reward already claimed for this flashcard.",
      );
      return;
    }

    bool result = await Get.toNamed(
      EpicRoutes.flashcardReward,
      arguments: flashcard,
    );

    if (result == true) {
      try {
        final history = await childrenUsecase.getFlashcardHistoryById(
          flashcard.flashcardId ?? '',
        );

        if (history != null) {
          flashcardHistory.value = history;
          isRewardClaimed.value =
              flashcardHistory.value?.claimedRewards != null &&
                  flashcardHistory.value!.claimedRewards!.isNotEmpty;
          _updateClaimedFlag();
          EpicLog.debug('Flashcard history refreshed after claiming rewards.');
        } else {
          EpicLog.debug(
              'No flashcard history found to refresh after claiming rewards.');
        }
      } catch (ex, s) {
        EpicLog.exception(ex, s, this, 'goToClaimReward - refresh history');
      }
    }
  }

  void _updateClaimedFlag() {
    final claimed = flashcardHistory.value?.claimedRewards;
    isRewardClaimed.value = claimed != null && claimed.isNotEmpty;
  }
}
