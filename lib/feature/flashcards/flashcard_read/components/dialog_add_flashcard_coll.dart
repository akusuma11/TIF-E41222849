import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_read_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const List<int> _fallbackGradientIndexes = [2, 7, 6];
const List<String> _thumbAssets = [
  'assets/images/flashcard-bhs-indo.png',
  'assets/images/flashcard-matematika.png',
  'assets/images/tipe-flashcard.png',
];

void showAddFlashcardCollectionSheet(
  BuildContext context,
  FlashcardReadController controller,
  FlashcardEntity flashcard,
) {
  Get.bottomSheet(
    SafeArea(
      top: false,
      child: Obx(
        () {
          final items = controller.collections;

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFC6B2E6),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(EpicSize.calculatedSize(34)),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              EpicSize.calculatedSize(16),
              EpicSize.calculatedSize(14),
              EpicSize.calculatedSize(16),
              EpicSize.calculatedSize(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Collection',
                  style: EpicSize.titleLarge.copyWith(
                    fontSize: EpicSize.calculatedSize(28),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111111),
                  ),
                ),
                SizedBox(height: EpicSize.calculatedSize(20)),
                if (items.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: EpicSize.calculatedSize(24),
                    ),
                    child: Text(
                      'Belum ada koleksi flashcard.',
                      style: EpicSize.bodyMedium.copyWith(
                        fontSize: EpicSize.calculatedSize(16),
                        color: const Color(0xFF333333),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: EpicSize.calculatedSize(12)),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        final colorIndex = item.bgColor ??
                            _fallbackGradientIndexes[
                                index % _fallbackGradientIndexes.length];
                        final gradient = collectionColorAt(colorIndex).gradient;
                        final thumbAsset =
                            _thumbAssets[index % _thumbAssets.length];
                        final category = (item.categories != null &&
                                item.categories!.isNotEmpty)
                            ? item.categories!.first
                            : '-';

                        return _FlashcardCollectionSheetTile(
                          item: item,
                          category: category,
                          thumbnailAsset: thumbAsset,
                          gradient: gradient,
                          onAdd: () {
                            controller.addFlashcardToCollection(
                              collectionId: item.collectionId,
                              flashcardId: flashcard.flashcardId ?? '',
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _FlashcardCollectionSheetTile extends StatelessWidget {
  const _FlashcardCollectionSheetTile({
    required this.item,
    required this.category,
    required this.thumbnailAsset,
    required this.gradient,
    required this.onAdd,
  });

  final FlashCardCollectionEntity item;
  final String category;
  final String thumbnailAsset;
  final LinearGradient gradient;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(EpicSize.calculatedSize(10)),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(EpicSize.calculatedSize(20)),
        border: Border.all(color: const Color(0x99FFFFFF), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0x22000000),
            blurRadius: EpicSize.calculatedSize(8),
            offset: Offset(0, EpicSize.calculatedSize(2)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: EpicSize.calculatedSize(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EpicSize.titleMedium.copyWith(
                    fontSize: EpicSize.calculatedSize(20),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111111),
                  ),
                ),
                SizedBox(height: EpicSize.calculatedSize(7)),
                Wrap(
                  spacing: EpicSize.calculatedSize(6),
                  runSpacing: EpicSize.calculatedSize(6),
                  children: [
                    _chip(
                      icon: Icons.folder_open_outlined,
                      text: '${item.totalFlashcard ?? 0} kartu',
                    ),
                    _chip(text: category),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: EpicSize.calculatedSize(8)),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: EpicSize.calculatedSize(28),
                height: EpicSize.calculatedSize(28),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 47, 85, 255),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: EpicSize.calculatedSize(20),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required String text, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: EpicSize.calculatedSize(12),
        vertical: EpicSize.calculatedSize(9),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(EpicSize.calculatedSize(6)),
        border: Border.all(color: const Color(0xFF111111), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: EpicSize.calculatedSize(13),
                color: const Color(0xFF111111)),
            SizedBox(width: EpicSize.calculatedSize(4)),
          ],
          Text(
            text,
            style: EpicSize.bodySmall.copyWith(
              fontSize: EpicSize.calculatedSize(12),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: EpicSize.calculatedSize(64),
      height: EpicSize.calculatedSize(64),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(EpicSize.calculatedSize(14)),
        border: Border.all(color: const Color(0x44FFFFFF), width: 1.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.style_rounded,
          color: const Color(0xFF666666),
          size: EpicSize.calculatedSize(24),
        ),
      ),
    );
  }
}
