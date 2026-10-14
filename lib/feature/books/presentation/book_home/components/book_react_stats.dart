import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/feature/books/presentation/book_home/book_home_controller.dart';
import 'package:flutter/material.dart';

class ReactionStat extends StatelessWidget {
  final String symbol;
  final int count;
  final String symbolName;
  final BookHomeController bookController;
  final String bookId;

  const ReactionStat({
    super.key,
    required this.symbol,
    required this.count,
    required this.symbolName,
    required this.bookController,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        bookController.reactBook(
          bookId: bookId,
          emoticon: symbolName,
        );
      },
      child: Row(
        children: [
          Text(
            symbol,
            style: TextStyle(fontSize: EpicSize.sizeMediumLarge),
          ),
          SizedBox(width: EpicSize.sizeSuperSmall),
          Text(count.toString(), style: EpicSize.bodyLarge),
        ],
      ),
    );
  }
}
