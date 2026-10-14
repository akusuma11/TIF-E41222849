import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/feature/books/presentation/book_histories/state/book_histories_state.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookHomePage extends StatelessWidget {
  const BookHomePage({super.key});

  static const Color _mainBackground = Color(0xFFE0CEFF);
  static const double _historyCardWidth = 280;
  static const double _historyCardHeight = 152;
  static const List<Color> _gradientCycle = [
    Color(0xFFFFDAA0),
    Color(0xFFAAFFC0),
  ];

  @override
  Widget build(BuildContext context) {
    final BookHomeController controller = Get.find();

    return Scaffold(
      backgroundColor: _mainBackground,
      body: Obx(() {
        final bookById = {
          for (final book in controller.books)
            if (book.bookId != null) book.bookId!: book,
        };

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final histories = controller.filteredHistory;
        final latestHistories = histories.take(5).toList();
        final items = controller.filteredBooks;
        final learnCount = controller.uncompletedHistories.length;
        final quizCount = controller.completedHistories.length;

        return SingleChildScrollView(
          padding: EdgeInsets.only(left: 10, top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Riwayat Buku'),
              const SizedBox(height: 12),
              if (histories.isEmpty)
                _buildEmptyState(
                  'Belum ada riwayat baca di kategori "${controller.selectedCategory.value}"',
                )
              else
                SizedBox(
                  height: _historyCardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: latestHistories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      if (index == latestHistories.length) {
                        return _buildSeeAllHistoriesButton(
                          index: index,
                          onTap: () => controller.goToBookHistories(
                            BookHistoriesState.allHistories,
                          ),
                        );
                      }

                      final history = latestHistories[index];
                      final linkedBook = history.bookId == null
                          ? null
                          : bookById[history.bookId!];

                      return _buildHistoryCard(
                        history,
                        linkedBook,
                        index,
                        onTap: () {
                          controller.gotoBookReadFromHistory(history);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              _buildActionButtons(
                learnCount: learnCount,
                quizCount: quizCount,
                onTapLearn: () {
                  controller
                      .goToBookHistories(BookHistoriesState.learnHistories);
                },
                onTapQuiz: () {
                  controller
                      .goToBookHistories(BookHistoriesState.quizHistories);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Buku yang dapat kamu pelajari'),
              const SizedBox(height: 10),
              if (items.isEmpty)
                _buildEmptyState(
                  'Belum ada buku di kategori "${controller.selectedCategory.value}"',
                )
              else
                ListView.separated(
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildBookLearningCard(
                      items[index],
                      index,
                      onTap: () {
                        controller.goToBookRead(items[index]);
                      },
                    );
                  },
                ),
              SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
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

  Widget _buildHistoryCard(
    BookHistoryEntity history,
    BookEntity? linkedBook,
    int index, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _historyCardWidth,
        height: _historyCardHeight,
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: _cardDecoration(index),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookImage(
              coverUrl: history.bookCover,
              category: linkedBook?.category ?? history.category,
              index: index,
              width: 96,
              height: 132,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.title ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    linkedBook?.summary ?? '-',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF232323),
                      height: 1.2,
                    ),
                  ),
                  const Spacer(),
                  _miniPill(
                    icon: Icons.label_outline,
                    label:
                        history.category ?? linkedBook?.category ?? 'Lainnya',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeAllHistoriesButton({
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: _historyCardHeight,
        decoration: _cardDecoration(index),
        child: const Center(
          child: Icon(
            Icons.arrow_right_alt_rounded,
            size: 30,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required int learnCount,
    required int quizCount,
    required VoidCallback onTapLearn,
    required VoidCallback onTapQuiz,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCapsule(
            label: 'Belajar=$learnCount',
            imagePath: 'assets/images/yellow-button.png',
            onPressed: onTapLearn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCapsule(
            label: 'Kuis=$quizCount',
            imagePath: 'assets/images/green-button.png',
            onPressed: onTapQuiz,
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

  Widget _buildBookLearningCard(
    BookEntity item,
    int index, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
        decoration: _cardDecoration(index),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookImage(
                  coverUrl: item.bookCover,
                  category: item.category,
                  index: index,
                  width: 144,
                  height: 164,
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 12),
                      Text(
                        'Category : ${item.category ?? '-'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF232323),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Halaman : ${item.totalPages ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF232323),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.summary ?? '-',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF232323),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _buildReadLabel(item.reads),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF232323),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage({
    required String? coverUrl,
    required String? category,
    required int index,
    required double width,
    required double height,
  }) {
    final fallbackAsset = _resolveFallbackBookAsset(category, index);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        height: height,
        child: coverUrl != null && coverUrl.trim().isNotEmpty
            ? Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  fallbackAsset,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                fallbackAsset,
                fit: BoxFit.cover,
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

  String _resolveFallbackBookAsset(String? category, int index) {
    final normalized = (category ?? '').toLowerCase();

    if (normalized.contains('matematika') || normalized.contains('ipa')) {
      return 'assets/images/book-matematika.png';
    }
    if (normalized.contains('bahasa') || normalized.contains('indo')) {
      return 'assets/images/book-bhs-indo.png';
    }

    return index.isEven
        ? 'assets/images/book-matematika.png'
        : 'assets/images/book-bhs-indo.png';
  }

  String _buildReadLabel(int? reads) {
    final value = reads ?? 0;
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} rb x dibaca';
    }
    return '$value x dibaca';
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
            Color(0xFFAAFFC0),
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
