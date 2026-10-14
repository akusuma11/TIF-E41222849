import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/children_collection_entity.dart';
import 'package:epic_story_app/feature/books/presentation/book_read/book_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<int> _fallbackGradientIndexes = [2, 7, 6];
const List<String> _thumbAssets = [
  'assets/images/book-bhs-indo.png',
  'assets/images/book-matematika.png',
  'assets/images/tipe-book.png',
];

void showAddBookCollectionSheet(
  BuildContext context,
  BookReadController controller,
  BookEntity book,
) {
  Get.bottomSheet(
    SafeArea(
      top: false,
      child: Obx(
        () {
          final items = controller.collections;
          final media = MediaQuery.of(context);
          final isLandscape = media.orientation == Orientation.landscape;
          final sheetMaxWidth = isLandscape
              ? (media.size.width * 0.52).clamp(300.0, 430.0).toDouble()
              : media.size.width;
          final listMaxHeight = media.size.height * (isLandscape ? 0.34 : 0.50);

          return Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sheetMaxWidth),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFC6B2E6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Collection',
                      style: EpicSize.titleLarge.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Belum ada koleksi buku.',
                          style: EpicSize.bodyMedium.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: listMaxHeight,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final item = items[index];
                            final colorIndex = item.bgColor ??
                                _fallbackGradientIndexes[
                                    index % _fallbackGradientIndexes.length];
                            final gradient =
                                collectionColorAt(colorIndex).gradient;
                            final thumbAsset =
                                _thumbAssets[index % _thumbAssets.length];

                            return _BookCollectionSheetTile(
                              item: item,
                              thumbnailAsset: thumbAsset,
                              gradient: gradient,
                              onAdd: () {
                                controller.addBookToCollection(
                                  collectionId: item.id,
                                  bookId: book.bookId ?? '',
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _BookCollectionSheetTile extends StatelessWidget {
  const _BookCollectionSheetTile({
    required this.item,
    required this.thumbnailAsset,
    required this.gradient,
    required this.onAdd,
  });

  final ChildrenCollectionEntity item;
  final String thumbnailAsset;
  final LinearGradient gradient;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x99FFFFFF), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0x22000000),
            blurRadius: 6,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _BookThumbnail(
            coverUrl: item.bookCovers?.isNotEmpty == true
                ? item.bookCovers!.first
                : null,
            fallbackAssetPath: thumbnailAsset,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EpicSize.titleMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                _chip(
                  icon: Icons.menu_book_rounded,
                  text: 'Total Buku : ${item.nBooks ?? 0}',
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 47, 85, 255),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required String text, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF111111), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: const Color(0xFF111111),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: EpicSize.bodySmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookThumbnail extends StatelessWidget {
  const _BookThumbnail({
    required this.coverUrl,
    required this.fallbackAssetPath,
  });

  final String? coverUrl;
  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x44FFFFFF), width: 1.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: (coverUrl != null && coverUrl!.trim().isNotEmpty)
          ? Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                fallbackAssetPath,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(
              fallbackAssetPath,
              fit: BoxFit.cover,
            ),
    );
  }
}
