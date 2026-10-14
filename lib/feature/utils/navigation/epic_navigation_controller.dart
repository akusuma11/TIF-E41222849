import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:get/get.dart';

class EpicNavigationController extends GetxController {
  EpicNavigationController();

  var isBook = false.obs;
  RxInt selectedIndex = 0.obs;

  // var refreshRewardHome = 0.obs;
  var refresRewardFlashcard = 0.obs;
  var refreshRewardBook = 0.obs;
  var refreshCollectionHome = 0.obs;

  var selectedCategory = "".obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    ever(selectedCategory, (value) {
      EpicLog.debug("Selected category: $value");
    });
  }
}
