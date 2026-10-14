import 'package:epic_story_app/core/widgets/cards/stacked_info_top_bar.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_page.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_home/flashcard_home_page.dart';
import 'package:epic_story_app/feature/home/enums/home_state.dart';
import 'package:epic_story_app/feature/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class HomeContentState extends StatelessWidget {
  final HomeController controller;

  static const Color _mainBackground = Color(0xFFE0CEFF);

  const HomeContentState({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isBookMode = controller.navController.isBook.value;
      final String selectedCategory =
          controller.navController.selectedCategory.value;
      final String activeCategory =
          selectedCategory.isEmpty ? 'Semua' : selectedCategory;
      final String infoText = 'Mata Pelajaran :\n$activeCategory';

      return Container(
        width: double.infinity,
        color: _mainBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StackedInfoTopBar(
                titleText: isBookMode ? 'Buku' : 'Flashcard',
                infoText: infoText,
                isBackButtonVisible: true,
                onBackTap: () {
                  controller.state.value = HomeState.category;
                },
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0CEFF),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isBookMode
                      ? const BookHomePage()
                      : const FlashCardHomePage(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
