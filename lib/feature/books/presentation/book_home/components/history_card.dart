import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/components/book_cover.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final BookHistoryEntity item;
  final String? category;
  final String? summary;
  final BookHomeController controller;

  const HistoryCard({
    super.key,
    required this.item,
    this.category,
    this.summary,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.gotoBookReadFromHistory(item);
      },
      child: Container(
        width: EpicSize.calculatedSize(300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4D4D4D), width: 1),
        ),
        padding: EdgeInsets.all(EpicSize.sizeSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: EpicSize.calculatedSize(70),
              height: EpicSize.calculatedSize(92),
              child: BookCover(coverUrl: item.bookCover),
            ),
            SizedBox(width: EpicSize.sizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Judul belum tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: EpicSize.sizeSuperSmall),
                  Text(
                    summary ?? '-',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: EpicSize.sizeSuperSmall),
                  Text(
                    'Category : ${category ?? '-'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyHistoryState extends StatelessWidget {
  final String category;

  const EmptyHistoryState({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Belum ada riwayat baca di kategori "$category"',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
