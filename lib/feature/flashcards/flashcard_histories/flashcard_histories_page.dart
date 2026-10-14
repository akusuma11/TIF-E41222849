import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/core/widgets/cards/stacked_info_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'flashcard_histories_controller.dart';

class FlashcardHistoriesPage extends GetView<FlashcardHistoriesController> {
  const FlashcardHistoriesPage({super.key});

  static const Color _mainBackground = Color(0xFFE0CEFF);

  static const List<Color> _gradientCycle = [
    Color(0xFFFFE588),
    Color(0xFF77B4FF),
    Color(0xFF4EFF4F),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final histories = controller.histories;
      final selectedCategory =
          controller.flashcardHomeController.selectedCategory.value;
      final activeCategory =
          selectedCategory.isEmpty ? 'Semua' : selectedCategory;

      return Scaffold(
        backgroundColor: _mainBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StackedInfoTopBar(
                titleText: 'History Flashcard',
                infoText: 'Mata Pelajran :\n$activeCategory',
                isBackButtonVisible: true,
                onBackTap: () => Get.back(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: histories.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada riwayat flashcard.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2B2B2B),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: histories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => _HistoryItem(
                            item: histories[index],
                            index: index,
                            gradientCycle: _gradientCycle,
                            onTap: () =>
                                controller.openFromHistory(histories[index]),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.item,
    required this.index,
    required this.gradientCycle,
    required this.onTap,
  });

  final FlashcardHistoryEntity item;
  final int index;
  final List<Color> gradientCycle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientCycle[index % gradientCycle.length],
              const Color(0xFFFFFFFF),
            ],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 82,
                height: 82,
                color: Colors.white.withOpacity(0.72),
                child: Image.asset(
                  _resolveCategoryImage(item.category, index),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.summary ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF232323),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _pill(
                        Icons.collections_bookmark_outlined,
                        '${item.totalCards ?? 0} kartu',
                      ),
                      _pill(
                        Icons.quiz_outlined,
                        '${item.completedQuiz ?? 0}/${item.totalQuiz ?? (item.isHaveQuiz == true ? 1 : 0)}',
                      ),
                      _pill(Icons.label_outline, item.category ?? 'Lainnya'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Image.asset(
                (item.isFinished ?? false)
                    ? 'assets/images/icon-selesai.png'
                    : 'assets/images/icon-belum-selesai.png',
                width: 62,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF151515)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF151515),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveCategoryImage(String? category, int index) {
    final normalized = (category ?? '').toLowerCase();
    if (normalized.contains('matematika') || normalized.contains('ipa')) {
      return 'assets/images/flashcard-matematika.png';
    }
    if (normalized.contains('bahasa') || normalized.contains('indo')) {
      return 'assets/images/flashcard-bhs-indo.png';
    }
    return index % 2 == 0
        ? 'assets/images/flashcard-bhs-indo.png'
        : 'assets/images/flashcard-matematika.png';
  }
}
