import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/domain/entities/children_collection_entity.dart';
import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final ChildrenCollectionEntity item;
  final int index;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CollectionCard({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categories = item.categories ?? const [];
    final visibleCategories = categories.isNotEmpty
        ? categories.take(2).toList()
        : const ['Kategori 1'];
    final baseColor = collectionColorAt(item.bgColor ?? index).color;
    final cardColor = Color.lerp(baseColor, Colors.white, 0.45)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverStack(covers: item.bookCovers, accentColor: baseColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? 'Nama Koleksi Buku',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111111),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.desc ??
                              'Deskripsi koleksi belum tersedia untuk saat ini.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1D1D1D),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: visibleCategories
                              .map((cat) => _MetaChip(text: cat))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _DeleteBadge(onTap: onDelete),
              ],
            ),
            const SizedBox(height: 8),
            _TotalBooksBadge(total: item.nBooks ?? 0),
          ],
        ),
      ),
    );
  }
}

class _CoverStack extends StatelessWidget {
  final List<String>? covers;
  final Color accentColor;

  const _CoverStack({
    this.covers,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = (covers ?? const <String>[])
        .where((cover) => cover.trim().isNotEmpty)
        .toList();
    final displayed = items.take(3).toList();
    final count = displayed.isEmpty ? 1 : displayed.length;

    return SizedBox(
      width: 110,
      height: 128,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < count; i++)
            Positioned(
              left: i * 7,
              top: i * 3,
              child: _CoverBox(
                width: 94,
                height: 118,
                url: displayed.isEmpty
                    ? null
                    : displayed[displayed.length - 1 - i],
                opacity: 1 - (i * 0.15),
                accentColor: accentColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverBox extends StatelessWidget {
  final double width;
  final double height;
  final String? url;
  final double opacity;
  final Color accentColor;

  const _CoverBox({
    required this.width,
    required this.height,
    required this.url,
    required this.opacity,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            border: Border.all(color: const Color(0xFF111111), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: url != null
              ? Image.network(
                  url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _placeholder(isLoading: true);
                  },
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder({bool isLoading = false}) {
    return Center(
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 26,
                  color: Color(0xFF6B6B6B),
                ),
                SizedBox(height: 4),
                Text(
                  'Cover Buku',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;

  const _MetaChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF111111), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111111),
          height: 1.1,
        ),
      ),
    );
  }
}

class _TotalBooksBadge extends StatelessWidget {
  final int total;

  const _TotalBooksBadge({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF111111), width: 1),
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 16,
            color: Color(0xFFA35BE2),
          ),
          const SizedBox(width: 4),
          Text(
            'Total Buku : $total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111111),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const _DeleteBadge({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
