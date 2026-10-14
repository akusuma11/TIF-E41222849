import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/core/widgets/cards/stacked_info_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'book_histories_controller.dart';

class BookHistoriesPage extends GetView<BookHistoriesController> {
  const BookHistoriesPage({super.key});

  static const Color _mainBackground = Color(0xFFE0CEFF);

  static const List<Color> _gradientCycle = [
    Color(0xFFFFDAA0),
    Color(0xFFAAFFC0),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final histories = controller.histories;
      final selectedCategory =
          controller.bookHomeController.selectedCategory.value;
      final activeCategory =
          selectedCategory.isEmpty ? 'Semua' : selectedCategory;
      final bookById = {
        for (final book in controller.bookHomeController.books)
          if (book.bookId != null) book.bookId!: book,
      };

      return Scaffold(
        backgroundColor: _mainBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StackedInfoTopBar(
                titleText: 'Riwayat Buku',
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
                            'Belum ada riwayat buku.',
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
                          itemBuilder: (context, index) {
                            final history = histories[index];
                            final linkedBook = history.bookId == null
                                ? null
                                : bookById[history.bookId!];

                            return _HistoryItem(
                              item: history,
                              index: index,
                              linkedBook: linkedBook,
                              gradientCycle: _gradientCycle,
                              onTap: () => controller.openFromHistory(history),
                            );
                          },
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
    required this.linkedBook,
    required this.gradientCycle,
    required this.onTap,
  });

  final BookHistoryEntity item;
  final int index;
  final BookEntity? linkedBook;
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
            _buildBookImage(
              coverUrl: item.bookCover,
              category: linkedBook?.category ?? item.category,
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
                  const SizedBox(height: 10),
                  Text(
                    'Category : ${item.category ?? linkedBook?.category ?? 'Kategori buku'}',
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
                    linkedBook?.summary ?? '-',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF232323),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        (item.isFinished ?? false)
                            ? 'assets/images/ic-book-selesai.png'
                            : 'assets/images/ic-book-belum-selesai.png',
                        width: 78,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage({
    required String? coverUrl,
    required String? category,
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
}
