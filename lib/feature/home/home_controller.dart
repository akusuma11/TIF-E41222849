import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/children_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_home/flashcard_home_controller.dart';
import 'package:epic_story_app/feature/home/components/category_state_widget.dart';
import 'package:epic_story_app/feature/home/components/home_content_state.dart';
import 'package:epic_story_app/feature/home/components/home_state_widget.dart';
import 'package:epic_story_app/feature/home/enums/home_state.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final FlashCardUsecase flashCardUsecase;
  final ChildrenUsecase childrenUsecase;
  final BookUsecase bookUsecase;
  final CollectionUsecase collectionUsecase;

  HomeController({
    required this.flashCardUsecase,
    required this.childrenUsecase,
    required this.bookUsecase,
    required this.collectionUsecase,
  });

  var isLoading = false.obs;
  var state = HomeState.home.obs;

  final mainController = Get.find<MainController>();
  final navController = Get.find<EpicNavigationController>();
  final flashcardController = Get.find<FlashCardHomeController>();
  final bookController = Get.find<BookHomeController>();

  final categories = <String>[].obs;
  Worker? _bookModeWorker;
  int _switchTicket = 0;

  @override
  void onInit() {
    super.onInit();

    _bookModeWorker = ever<bool>(navController.isBook, (value) {
      _syncContentForMode(value);
    });

    _syncContentForMode(navController.isBook.value);
  }

  @override
  void onClose() {
    _bookModeWorker?.dispose();
    super.onClose();
  }

  Future<void> _syncContentForMode(
    bool isBookMode, {
    bool forceReload = false,
  }) async {
    final ticket = ++_switchTicket;
    final shouldLoad = forceReload ||
        (isBookMode
            ? bookController.books.isEmpty
            : flashcardController.flashcards.isEmpty);

    if (shouldLoad) {
      isLoading.value = true;
    }

    try {
      if (isBookMode) {
        if (forceReload || bookController.books.isEmpty) {
          await bookController.loadBooks();
        }
        if (_isStale(ticket)) return;
        categories.assignAll(bookController.categories);
      } else {
        if (forceReload || flashcardController.flashcards.isEmpty) {
          await flashcardController.fetchFlashcards();
        }
        if (_isStale(ticket)) return;
        categories.assignAll(flashcardController.categories);
      }
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, '_syncContentForMode');
    } finally {
      if (!_isStale(ticket)) {
        isLoading.value = false;
      }
    }
  }

  bool _isStale(int ticket) => isClosed || ticket != _switchTicket;

  Future<void> refreshCurrentView() async {
    await _syncContentForMode(
      navController.isBook.value,
      forceReload: true,
    );
  }

  Widget getState() {
    switch (state.value) {
      case HomeState.home:
        return HomeStateWidget(controller: this);
      case HomeState.category:
        return CategoryStateWidget(controller: this);
      case HomeState.content:
        return HomeContentState(controller: this);
    }
  }

  void onBack() {
    isLoading.value = false;
    if (state.value == HomeState.home) return;
    if (state.value == HomeState.category) {
      state.value = HomeState.home;
    } else if (state.value == HomeState.content) {
      state.value = HomeState.category;
    }
  }
}
