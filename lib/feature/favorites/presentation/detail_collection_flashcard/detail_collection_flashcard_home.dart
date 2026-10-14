import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/core/widgets/cards/collection_top_section.dart';
import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_detail_item_entity.dart';
import 'package:epic_story_app/feature/favorites/presentation/detail_collection_flashcard/detail_collection_flashcard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

double _s(double value) => EpicAppSize.calculatedSize(value);

class DetailCollectionFlashcardHome
    extends GetView<DetailCollectionFlashcardController> {
  const DetailCollectionFlashcardHome({super.key});

  static const List<int> _gradientIndexes = [2, 7, 6];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6B2E6),
      body: SafeArea(
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = controller.collectionDetail.value;
          final isDetailReady = detail != null;
          final items = detail?.flashcards ?? [];

          return Column(
            children: [
              CollectionTopSection(
                title: 'Detail Koleksi',
                onBackTap: Get.back,
                leftIconAssetPath: 'assets/images/Book Stacks 1.png',
                mascotAssetPath: 'assets/images/icon-top-bar.png',
                yellowButtonAssetPath: 'assets/images/blue-button.png',
                yellowButtonText: 'Flashcard',
                titleTextSize: 37,
                yellowButtonTextSize: 22,
                yellowButtonWidth: 172,
                yellowButtonHeight: 54,
              ),
              if (detail != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(_s(16), _s(10), _s(16), 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      detail.title ?? 'Koleksi Flashcard',
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
                        backgroundColor: const Color(0xFFAAFFC0),
                        textColor: const Color(0xFF111111),
                        onTap: isDetailReady
                            ? controller.goToEditCollection
                            : null,
                      ),
                      _ActionButton(
                        label: 'Hapus Koleksi',
                        icon: Icons.delete,
                        backgroundColor: const Color(0xFFFF0000),
                        textColor: Colors.white,
                        onTap:
                            isDetailReady ? controller.deleteCollection : null,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada flashcard dalam koleksi ini.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding:
                            EdgeInsets.fromLTRB(_s(16), _s(12), _s(16), _s(16)),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final palette = collectionColorAt(
                            _gradientIndexes[index % _gradientIndexes.length],
                          );

                          return _FlashcardRow(
                            item: item,
                            gradient: palette.gradient,
                            controller: controller,
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(height: _s(12)),
                        itemCount: items.length,
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FlashcardRow extends StatelessWidget {
  final FlashCardCollectionDetailItemEntity item;
  final LinearGradient gradient;
  final DetailCollectionFlashcardController controller;

  const _FlashcardRow({
    required this.item,
    required this.gradient,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.goToFlashcardRead(flashcardId: item.flashcardId ?? '');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(_s(20)),
          border: Border.all(color: const Color(0x99FFFFFF), width: _s(1.2)),
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: _s(7),
              offset: Offset(0, _s(3)),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(_s(12), _s(10), _s(12), _s(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _s(21),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: _s(4)),
                        Text(
                          item.summary ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _s(14),
                            height: 1.35,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: _s(8)),
                  GestureDetector(
                    onTap: () {
                      controller.deleteBookFromCollection(item);
                    },
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
              SizedBox(height: _s(9)),
              Wrap(
                spacing: _s(6),
                runSpacing: _s(6),
                children: [
                  _chip(
                    text: '${item.totalCards ?? 0} kartu',
                    icon: Icons.folder_open_outlined,
                  ),
                  _chip(text: item.category ?? '-'),
                  _chip(
                    text: '${item.completedQuiz ?? 0}/${item.totalQuiz ?? 0}',
                    icon: Icons.assignment_outlined,
                  ),
                ],
              ),
              SizedBox(height: _s(8)),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '',
                  style: TextStyle(
                    fontSize: _s(12),
                    color: const Color(0xFF111111),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({required String text, IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _s(7), vertical: _s(3)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(_s(6)),
        border: Border.all(color: const Color(0xFF111111), width: _s(0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: _s(13), color: const Color(0xFF111111)),
            SizedBox(width: _s(4)),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: _s(13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111111),
            ),
          ),
        ],
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
