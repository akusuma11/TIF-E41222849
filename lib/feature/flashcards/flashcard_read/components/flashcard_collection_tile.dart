import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:flutter/material.dart';

class CollectionTile extends StatelessWidget {
  final String title;
  final int totalBooks;
  final VoidCallback onAdd;

  const CollectionTile({
    super.key,
    required this.title,
    required this.totalBooks,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: EpicSize.radiusSmall,
        border: Border.all(color: Colors.black26),
      ),
      padding: EdgeInsets.all(EpicSize.sizeSmall),
      child: Row(
        children: [
          Container(
            width: EpicSize.calculatedSize(32),
            height: EpicSize.calculatedSize(32),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: EpicSize.radiusExtraSmall,
            ),
            child: const Icon(Icons.image, size: 18, color: Colors.black45),
          ),
          SizedBox(width: EpicSize.sizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      EpicSize.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: EpicSize.sizeSuperSmall),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: EpicSize.sizeSmall,
                    vertical: EpicSize.sizeSuperSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: EpicSize.radiusExtraSmall,
                    border: Border.all(color: Colors.black45),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.book_outlined, size: 14),
                      SizedBox(width: EpicSize.sizeSuperSmall),
                      Text('Total Buku : $totalBooks',
                          style: EpicSize.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: EpicSize.sizeSmall),
          OutlinedButton(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: EpicSize.sizeSmall,
                vertical: EpicSize.sizeSuperSmall,
              ),
              side: const BorderSide(color: Colors.black45),
            ),
            child: Icon(Icons.add,
                color: Colors.black45, size: EpicSize.calculatedSize(20)),
          ),
        ],
      ),
    );
  }
}
