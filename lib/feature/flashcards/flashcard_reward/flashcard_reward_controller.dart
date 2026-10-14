import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:get/get.dart';

class FlashcardRewardController extends GetxController {
  late FlashcardEntity flashcard;
  final rewards = <String>[].obs;
  final selectedQueue = <int>[].obs;

  static const int maxSelection = 3;

  final mainController = Get.find<MainController>();

  String? get selectedReward =>
      selectedQueue.isNotEmpty && selectedQueue.last < rewards.length
          ? rewards[selectedQueue.last]
          : null;

  List<String> get selectedRewardsOrdered => selectedQueue
      .where((index) => index >= 0 && index < rewards.length)
      .map((index) => rewards[index])
      .toList();

  int get remainingSelection =>
      (maxSelection - selectedCount).clamp(0, maxSelection);

  int get selectedCount => selectedQueue.length;

  bool get hasRewards => rewards.isNotEmpty;
  int get totalReward => rewards.length;

  var flashcardHistory = Rxn(FlashcardHistoryEntity());

  final ChildrenUsecase childrenUsecase;

  FlashcardRewardController({
    required this.childrenUsecase,
  });

  @override
  void onInit() async {
    super.onInit();
    flashcard = const FlashcardEntity(rewards: []);

    final argument = Get.arguments;
    if (argument != null && argument is FlashcardEntity) {
      flashcard = argument;
      flashcardHistory.value = await childrenUsecase.getFlashcardHistoryById(
        flashcard.flashcardId ?? '',
      );
    }

    rewards.assignAll(flashcard.rewards ?? []);
  }

  void selectReward(int index) {
    if (index < 0 || index >= rewards.length) return;

    // Toggle off if already selected
    if (selectedQueue.contains(index)) {
      selectedQueue.remove(index);
      EpicLog.debug('Selected rewards: ${selectedQueue.join(' - ')}');
      return;
    }

    // Keep only the latest [maxSelection] picks; drop the oldest if over limit.
    if (selectedQueue.length >= maxSelection) {
      selectedQueue.removeAt(0);
    }

    selectedQueue.add(index);

    EpicLog.debug('Selected rewards: ${selectedQueue.join(' - ')}');
  }

  void removeSelectionAt(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= selectedQueue.length) return;
    selectedQueue.removeAt(slotIndex);
    EpicLog.debug('Removed selection at slot $slotIndex');
  }

  void claimReward() async {
    try {
      if (selectedQueue.length < maxSelection) {
        EpicLog.debug('Please select $maxSelection rewards before claiming.');
        EpicSnackBar.showWarningSnackBar(
          "Pilih Reward",
          "Silakan pilih $maxSelection gambar terlebih dahulu.",
        );
        return;
      }

      var newHistory = flashcardHistory.value?.copyWith(
        claimedRewards: selectedQueue,
      );

      if (newHistory != null) {
        mainController.showLoadingPage();
        bool result = await childrenUsecase.updateFlashcardHistory(
          flashcardHistory: newHistory,
          pushToRemote: true,
        );
        flashcardHistory.value = newHistory;
        if (result) {
          mainController.hideLoadingPage();
          Get.back(result: true);
          EpicSnackBar.showSuccessSnackBar(
              "Success", "Rewards claimed successfully!");
        } else {
          EpicSnackBar.showErrorSnackBar(
              "Error", "Failed to claim rewards. Please try again.");
        }
      } else {
        EpicLog.debug('No flashcard history found to update.');
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'claimReward');
    } finally {
      mainController.hideLoadingPage();
    }
  }
}
