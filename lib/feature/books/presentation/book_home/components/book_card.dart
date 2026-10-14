import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/components/book_cover.dart';
import 'package:epic_story_app/feature/books/presentation/book_read/components/dialog_add_book_coll.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final BookEntity item;
  final BookHomeController controller;

  const BookCard({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final book = item;

    return GestureDetector(
      onTap: () {
        controller.goToBookRead(book);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4D4D4D), width: 1),
        ),
        padding: EdgeInsets.all(EpicSize.sizeMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: EpicSize.calculatedSize(90),
                  height: EpicSize.calculatedSize(122),
                  child: BookCover(coverUrl: book.bookCover),
                ),
                SizedBox(width: EpicSize.sizeSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title ?? 'Judul belum tersedia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: EpicSize.sizeSuperSmall),
                      Text(
                        'Category : ${book.category ?? '-'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: EpicSize.sizeSuperSmall),
                      Text(
                        'Total Halaman : ${book.totalPages ?? 0}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: EpicSize.sizeSuperSmall),
                      Text(
                        book.summary ?? '--',
                        style: TextStyle(
                          color: Colors.black,
                          height: 1.2,
                          fontSize: 12,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: EpicSize.sizeSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _buildReadLabel(book.reads),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildReadLabel(int? reads) {
    final value = reads ?? 0;
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} rb x dibaca';
    }
    return '$value x dibaca';
  }
}
