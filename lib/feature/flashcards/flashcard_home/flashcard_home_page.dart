import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_histories/state/flashcard_history_state.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_home/flashcard_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashCardHomePage extends GetView<FlashCardHomeController> {
  const FlashCardHomePage({super.key});

  static const Color _mainBackground = Color(0xFFE0CEFF);
  static const double _historyCardWidth = 200;
  static const double _historyCardHeight = 120;
  static const List<Color> _gradientCycle = [
    Color(0xFFFFE588),
    Color(0xFF77B4FF),
    Color(0xFF4EFF4F),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainBackground,
      body: Obx(
        () {
          final history = controller.filteredHistory;
          final latestHistory = history.take(5).toList();
          final recommendations = controller.filteredRecommendations;
          final learnCount = controller.uncompletedFlashcardHistories.length;
          final quizCount = controller.completedFlashcardHistories.length;

          return SingleChildScrollView(
            padding: EdgeInsets.only(left: 10, top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Riwayat Flashcard'),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  _buildEmptyState('Belum ada riwayat untuk kategori ini.')
                else
                  _buildStackedHistoryList(latestHistory),
                const SizedBox(height: 24),
                _buildActionButtons(learnCount, quizCount),
                const SizedBox(height: 24),
                _buildSectionTitle('Flashcard yang dapat kamu pelajari'),
                const SizedBox(height: 10),
                if (recommendations.isEmpty)
                  _buildEmptyState(
                      'Belum ada flashcard yang dapat kamu pelajari.')
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _buildRecommendationCard(
                      recommendations[index],
                      index,
                    ),
                  ),
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStackedHistoryList(List<FlashcardHistoryEntity> latestHistory) {
    final totalItems = latestHistory.length + 1;
    final totalColumns = (totalItems / 2).ceil();

    return SizedBox(
      height: (_historyCardHeight * 2) + 12,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(totalColumns, (columnIndex) {
            final topIndex = columnIndex * 2;
            final bottomIndex = topIndex + 1;

            return Padding(
              padding: EdgeInsets.only(
                right: columnIndex == totalColumns - 1 ? 0 : 12,
              ),
              child: Column(
                children: [
                  _buildStackedHistoryItem(topIndex, latestHistory),
                  const SizedBox(height: 12),
                  _buildStackedHistoryItem(bottomIndex, latestHistory),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStackedHistoryItem(
    int index,
    List<FlashcardHistoryEntity> latestHistory,
  ) {
    final seeAllIndex = latestHistory.length;

    if (index > seeAllIndex) {
      return const SizedBox(
        width: _historyCardWidth,
        height: _historyCardHeight,
      );
    }

    if (index == seeAllIndex) {
      return _buildSeeAllHistoryButton(index);
    }

    return _buildHistoryCard(latestHistory[index], index);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Colors.black,
        height: 1,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildHistoryCard(FlashcardHistoryEntity item, int index) {
    return GestureDetector(
      onTap: () {
        controller.goToFlashcardReadFromHistory(item);
      },
      child: Container(
        width: _historyCardWidth,
        height: _historyCardHeight,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: _cardDecoration(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _miniPill(
                  icon: Icons.collections_bookmark_outlined,
                  label: '${item.totalCards ?? 0}',
                ),
                const SizedBox(width: 6),
                _miniPill(
                  icon: Icons.quiz_outlined,
                  label:
                      '${item.completedQuiz ?? 0}/${item.totalQuiz ?? (item.isHaveQuiz == true ? 1 : 0)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeAllHistoryButton(int index) {
    return GestureDetector(
      onTap: () {
        controller.goToFlashcardHistories(
          FlashcardHistoryState.allHistories,
        );
      },
      child: Container(
        width: _historyCardWidth,
        height: _historyCardHeight,
        decoration: _cardDecoration(index),
        child: const Center(
          child: Icon(
            Icons.arrow_right_alt_rounded,
            size: 32,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(int learnCount, int quizCount) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCapsule(
            label: 'Belajar ($learnCount)',
            imagePath: 'assets/images/yellow-button.png',
            onPressed: () {
              controller
                  .goToFlashcardHistories(FlashcardHistoryState.learnHistories);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCapsule(
            label: 'Kuis ($quizCount)',
            imagePath: 'assets/images/green-button.png',
            onPressed: () {
              controller
                  .goToFlashcardHistories(FlashcardHistoryState.quizHistories);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCapsule({
    required String label,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.fill,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1,
                shadows: [
                  Shadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(FlashcardEntity item, int index) {
    return GestureDetector(
      onTap: () {
        controller.goToFlashcardRead(item);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: _cardDecoration(index),
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
                      _miniPill(
                        icon: Icons.collections_bookmark_outlined,
                        label: '${item.totalCards ?? 0} kartu',
                      ),
                      _miniPill(
                        icon: Icons.label_outline,
                        label: item.category ?? 'Lainnya',
                      ),
                      Text(
                        '${item.reads ?? 0}x dibaca',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF232323),
                        ),
                      ),
                    ],
                  ),
                  // if (totalQuiz > 0)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 6),
                  //     child: _miniPill(
                  //       icon: Icons.task_alt_outlined,
                  //       label:
                  //           '${completedQuiz.clamp(0, totalQuiz)}/${totalQuiz.clamp(0, 99)} kuis',
                  //     ),
                  //   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniPill({
    required IconData icon,
    required String label,
  }) {
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

  BoxDecoration _cardDecoration(int index) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _gradientCycle[index % _gradientCycle.length],
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
      );

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF77B4FF),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF151515), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF151515),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
