import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/core/widgets/cards/collection_top_section.dart';
import 'package:epic_story_app/domain/entities/collection_book_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detail_collection_controller.dart';

double _s(double value) => EpicAppSize.calculatedSize(value);

class DetailCollectionPage extends StatelessWidget {
  const DetailCollectionPage({super.key});

  static const List<Color> _itemColors = [
    Color(0xFFFFE070),
    Color(0xFFFFDAA0),
    Color(0xFFAAFFC0),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DetailCollectionController>();

    return Scaffold(
      backgroundColor: const Color(0xFFC6B2E6),
      body: SafeArea(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = controller.collectionDetail.value;
          if (detail == null) {
            return Center(
              child: Text(
                'Detail koleksi tidak tersedia',
                style: TextStyle(fontSize: _s(15)),
              ),
            );
          }

          final books = detail.books ?? [];

          return Column(
            children: [
              CollectionTopSection(
                title: 'Detail Koleksi',
                onBackTap: Get.back,
                leftIconAssetPath: 'assets/images/Book Stacks 1.png',
                mascotAssetPath: 'assets/images/icon-top-bar.png',
                yellowButtonAssetPath: 'assets/images/yellow-button.png',
                yellowButtonText: 'Book',
                titleTextSize: 39,
                yellowButtonTextSize: 36,
                yellowButtonWidth: 150,
                yellowButtonHeight: 52,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(_s(16), _s(10), _s(16), 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    detail.title ?? 'Koleksi Buku',
                    style: TextStyle(
                      fontSize: _s(22),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111111),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(_s(16), _s(6), _s(16), 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: _s(8),
                    runSpacing: _s(8),
                    children: [
                      _ActionButton(
                        label: 'Edit Koleksi',
                        icon: Icons.edit,
                        backgroundColor: const Color(0xFFFFE070),
                        textColor: const Color(0xFF111111),
                        onTap: controller.goToEditCollection,
                      ),
                      _ActionButton(
                        label: 'Hapus Koleksi',
                        icon: Icons.delete,
                        backgroundColor: const Color(0xFFFF0000),
                        textColor: Colors.white,
                        onTap: controller.deleteCollection,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: books.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada buku di koleksi ini',
                          style: TextStyle(
                            fontSize: _s(15),
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(0, _s(8), 0, _s(20)),
                        itemCount: books.length,
                        separatorBuilder: (_, __) => SizedBox(height: _s(12)),
                        itemBuilder: (_, index) {
                          final book = books[index];
                          final color = _itemColors[index % _itemColors.length];
                          return _BookItem(
                            book: book,
                            backgroundColor: color,
                            onTap: () => controller.goToBookRead(book),
                            onDelete: () async {
                              await controller.deleteBookFromCollection(book);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BookItem extends StatelessWidget {
  final CollectionBookEntity book;
  final Color backgroundColor;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const _BookItem({
    required this.book,
    required this.backgroundColor,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuiz = book.totalQuiz ?? 0;
    final completedQuiz = book.completedQuiz ?? 0;
    final totalPages = book.nPages ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(_s(12), _s(12), _s(12), _s(8)),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.white, width: _s(1)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverPlaceholder(coverUrl: book.coverUrl),
                SizedBox(width: _s(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              book.title ?? '-'.toUpperCase(),
                              style: TextStyle(
                                fontSize: _s(20),
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF111111),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              width: _s(28),
                              height: _s(28),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF0000),
                                borderRadius: BorderRadius.circular(_s(4)),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: _s(22),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: _s(4)),
                      if (book.summary != null && book.summary!.isNotEmpty)
                        Text(
                          book.summary!,
                          style: TextStyle(
                            fontSize: _s(17),
                            height: 1.2,
                            color: const Color(0xFF1A1A1A),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: _s(10)),
                      Text(
                        'Category : ${(book.category != null && book.category!.isNotEmpty) ? book.category : 'Kategori buku'}',
                        style: TextStyle(
                          fontSize: _s(17),
                          color: const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: _s(18)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: _s(8)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _s(8),
                      vertical: _s(4),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFF111111), width: _s(1)),
                      color: const Color(0xFFF5E9AE),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/book-stack2.png',
                          width: _s(16),
                          height: _s(16),
                        ),
                        SizedBox(width: _s(4)),
                        Flexible(
                          child: Text(
                            '$completedQuiz dari $totalQuiz Kuis diselesaikan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _s(16),
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: _s(8)),
                Text(
                  'Total Halaman : $totalPages',
                  style: TextStyle(
                    fontSize: _s(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final bgColor =
        isDisabled ? backgroundColor.withOpacity(0.5) : backgroundColor;
    final fgColor = isDisabled ? textColor.withOpacity(0.6) : textColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_s(12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _s(12),
            vertical: _s(7),
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(_s(12)),
            border: Border.all(color: const Color(0xFF111111), width: _s(1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x33000000),
                blurRadius: _s(6),
                offset: Offset(0, _s(3)),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: _s(16), color: fgColor),
              SizedBox(width: _s(6)),
              Text(
                label,
                style: TextStyle(
                  fontSize: _s(14),
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final String? coverUrl;

  const _CoverPlaceholder({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _s(140),
      height: _s(140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_s(16)),
        border: Border.all(color: const Color(0xFF111111), width: _s(1.2)),
      ),
      alignment: Alignment.center,
      child: coverUrl != null && coverUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(_s(14)),
              child: Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                width: _s(140),
                height: _s(140),
                errorBuilder: (_, __, ___) => _fallbackText(),
              ),
            )
          : _fallbackText(),
    );
  }

  Widget _fallbackText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_book_rounded,
          size: _s(26),
          color: const Color(0xFF6B6B6B),
        ),
        SizedBox(height: _s(4)),
        Text(
          'Cover Buku',
          style: TextStyle(
            fontSize: _s(11),
            color: const Color(0xFF6B6B6B),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
