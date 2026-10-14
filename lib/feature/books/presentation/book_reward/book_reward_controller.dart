import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:get/get.dart';

class BookRewardController extends GetxController {
  BookRewardController({
    required this.childrenUsecase,
  });

  static const int maxSelection = 3;

  final ChildrenUsecase childrenUsecase;
  final mainController = Get.find<MainController>();

  late BookEntity book;

  final rewards = <String>[].obs;
  final selectedQueue = <int>[].obs;
  final bookHistory = Rxn<BookHistoryEntity>();

  int get selectedCount => selectedQueue.length;
  int get remainingSelection =>
      (maxSelection - selectedCount).clamp(0, maxSelection);
  bool get hasRewards => rewards.isNotEmpty;

  List<String> get selectedRewardsOrdered => selectedQueue
      .where((index) => index >= 0 && index < rewards.length)
      .map((index) => rewards[index])
      .toList();

  @override
  void onInit() async {
    super.onInit();
    book = const BookEntity();

    final argument = Get.arguments;
    if (argument != null && argument is BookEntity) {
      book = argument;
      final bookId = book.bookId;
      if (bookId != null && bookId.isNotEmpty) {
        bookHistory.value = await childrenUsecase.getBookHistoryById(bookId);
      }
    }

    _initRewards();
  }

  void _initRewards() {
    var rewardList = book.rewards ?? [];
    rewards.clear();
    rewards.addAll(rewardList);
  }

  void selectReward(int index) {
    if (index < 0 || index >= rewards.length) return;

    if (selectedQueue.contains(index)) {
      selectedQueue.remove(index);
      return;
    }

    if (selectedQueue.length >= maxSelection) {
      selectedQueue.removeAt(0);
    }

    selectedQueue.add(index);
  }

  void removeSelectionAt(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= selectedQueue.length) return;
    selectedQueue.removeAt(slotIndex);
  }

  Future<void> claimReward() async {
    try {
      if (selectedQueue.length < maxSelection) {
        EpicSnackBar.showWarningSnackBar(
          'Pilih Reward',
          'Silakan pilih $maxSelection gambar terlebih dahulu.',
        );
        return;
      }

      final history = bookHistory.value;
      if (history == null) {
        EpicSnackBar.showErrorSnackBar(
          'Error',
          'Riwayat buku tidak ditemukan.',
        );
        return;
      }

      final newHistory = history.copyWith(
        claimedRewards: List<int>.from(selectedQueue),
      );

      mainController.showLoadingPage();
      await childrenUsecase.updateBookHistory(
        bookHistory: newHistory,
        pushToRemote: true,
      );
      bookHistory.value = newHistory;

      mainController.hideLoadingPage();
      Get.back(result: true);
      EpicSnackBar.showSuccessSnackBar(
        'Success',
        'Rewards claimed successfully!',
      );
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'claimReward');
      EpicSnackBar.showErrorSnackBar(
        'Error',
        'Failed to claim rewards. Please try again.',
      );
    } finally {
      mainController.hideLoadingPage();
    }
  }
}
