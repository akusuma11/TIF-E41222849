import 'package:epic_story_app/core/widgets/cards/stacked_info_top_bar.dart';
import 'package:epic_story_app/feature/home/enums/home_state.dart';
import 'package:epic_story_app/feature/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class CategoryStateWidget extends StatelessWidget {
  final HomeController controller;

  static const Color _mainBackground = Color(0xFFE0CEFF);

  const CategoryStateWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isBookMode = controller.navController.isBook.value;
      final categories = _displayedCategories(controller.categories);

      return Container(
        width: double.infinity,
        color: _mainBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StackedInfoTopBar(
                titleText: isBookMode ? 'Buku' : 'Flashcard',
                infoText:
                    'Silahkan pilih mata pelajaran apa yang ingin kamu pelajari',
                isBackButtonVisible: true,
                onBackTap: () {
                  controller.state.value = HomeState.home;
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 68, 18, 20),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // _buildAllCategoryButton(
                      //   onTap: () {
                      //     controller.state.value = HomeState.content;
                      //     controller.navController.selectedCategory.value =
                      //         'Semua';
                      //   },
                      // ),
                      if (categories.isEmpty) ...[
                        const SizedBox(height: 16),
                        _buildEmptyCategory(),
                      ] else ...[
                        const SizedBox(height: 16),
                        ...List.generate(categories.length, (index) {
                          final category = categories[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    index == categories.length - 1 ? 0 : 16),
                            child: _buildCategoryCard(
                              category: category,
                              index: index,
                              isBookMode: isBookMode,
                              onTap: () {
                                controller.state.value = HomeState.content;
                                controller.navController.selectedCategory
                                    .value = category;
                              },
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<String> _displayedCategories(List<String> categories) {
    final filtered = categories
        .where((category) =>
            category.trim().isNotEmpty && category.toLowerCase() != 'semua')
        .toList();

    if (filtered.isNotEmpty) {
      return filtered;
    }

    return categories
        .where((category) => category.trim().isNotEmpty)
        .toList(growable: false);
  }

  Widget _buildCategoryCard({
    required String category,
    required int index,
    required bool isBookMode,
    required VoidCallback onTap,
  }) {
    if (isBookMode) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 126,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF262626), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              _resolveBookAsset(category, index),
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => _buildFallbackLabel(
                category,
                textColor: Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 126,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: _flashcardGradient(index),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1F1F1F), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 108,
              height: 108,
              padding: const EdgeInsets.all(4),
              alignment: Alignment.center,
              child: Image.asset(
                _resolveFlashcardAsset(category, index),
                fit: BoxFit.contain,
                errorBuilder: (context, _, __) => const Icon(
                  Icons.auto_stories,
                  size: 44,
                  color: Color(0xFF303030),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackLabel(
    String label, {
    required Color textColor,
  }) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildAllCategoryButton({
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7E32AB),
              Color(0xFF4D1E68),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF311045), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7E32AB).withOpacity(0.38),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'Semua',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD2B6EA)),
      ),
      child: const Text(
        'Tidak ada kategori',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF4D4060),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _resolveBookAsset(String category, int index) {
    final normalized = category.toLowerCase();

    if (normalized.contains('matematika')) {
      return 'assets/images/book-matematika.png';
    }
    if (normalized.contains('bahasa') || normalized.contains('indo')) {
      return 'assets/images/book-bhs-indo.png';
    }

    return index.isEven
        ? 'assets/images/book-bhs-indo.png'
        : 'assets/images/book-matematika.png';
  }

  String _resolveFlashcardAsset(String category, int index) {
    final normalized = category.toLowerCase();

    if (normalized.contains('matematika')) {
      return 'assets/images/flashcard-matematika.png';
    }
    if (normalized.contains('bahasa') || normalized.contains('indo')) {
      return 'assets/images/flashcard-bhs-indo.png';
    }

    return index.isEven
        ? 'assets/images/flashcard-bhs-indo.png'
        : 'assets/images/flashcard-matematika.png';
  }

  LinearGradient _flashcardGradient(int index) {
    if (index % 2 == 0) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFE588),
        ],
      );
    }

    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFF77B4FF),
      ],
    );
  }
}
