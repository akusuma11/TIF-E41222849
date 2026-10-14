import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_entity.dart';
import 'package:epic_story_app/feature/favorites/presentation/favorite_home/favorite_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashcardCollection extends StatelessWidget {
  const FlashcardCollection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoriteHomeController>();

    return Obx(() {
      final items = controller.flashcardCollections;
      if (items.isEmpty) {
        return ColoredBox(
          color: const Color(0xFFC6B2E6),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            children: const [
              SizedBox(height: 80),
              Center(
                child: Text(
                  'Belum ada koleksi flashcard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return ColoredBox(
        color: const Color(0xFFC6B2E6),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          itemBuilder: (context, index) {
            final item = items[index];
            return _FlashcardCollectionCard(
              item: item,
              index: index,
              controller: controller,
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemCount: items.length,
        ),
      );
    });
  }
}

class _FlashcardCollectionCard extends StatelessWidget {
  final FlashCardCollectionEntity item;
  final int index;
  final FavoriteHomeController controller;

  const _FlashcardCollectionCard({
    required this.item,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final categories = item.categories ?? const [];
    final totalCards = item.totalCards ?? 0;
    final totalFlashcard = item.totalFlashcard ?? 0;
    final paletteColor = collectionColorAt(item.bgColor ?? index);
    final topColor =
        Color.lerp(paletteColor.gradient.colors.last, Colors.white, 0.35)!;
    final coverAsset =
        _resolveCategoryImage(categories.isNotEmpty ? categories.first : null);

    return GestureDetector(
      onTap: () {
        controller.goToCollectionFlashcardDetail(item);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              topColor,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: paletteColor.color.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(65, 2, 36, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title ?? 'Nama Koleksi Flashcard',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101010),
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      controller.deleteFlashcardCollection(item);
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.84),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: paletteColor.color,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      coverAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.desc ??
                            'Deskripsi koleksi belum tersedia untuk saat ini.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: Color(0xFF1F1F1F),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _chip(
                            icon: Icons.collections_bookmark_outlined,
                            text:
                                '${totalCards > 0 ? totalCards : totalFlashcard} kartu',
                          ),
                          _chip(
                            text: categories.isNotEmpty
                                ? categories.first
                                : 'Lainnya',
                          ),
                          Text(
                            '- ${totalFlashcard}x dibaca',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required String text, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF111111), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF111111)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveCategoryImage(String? category) {
    final normalized = (category ?? '').toLowerCase();

    if (normalized.contains('matematika') ||
        normalized.contains('ipa') ||
        normalized.contains('sains')) {
      return 'assets/images/flashcard-matematika.png';
    }
    if (normalized.contains('bahasa') || normalized.contains('indo')) {
      return 'assets/images/flashcard-bhs-indo.png';
    }

    return index.isEven
        ? 'assets/images/flashcard-bhs-indo.png'
        : 'assets/images/flashcard-matematika.png';
  }
}
