import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  final String? coverUrl;

  const BookCover({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final double side = EpicSize.calculatedSize(110);

    return ClipRRect(
      borderRadius: EpicSize.radiusSmall,
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.black.withOpacity(0.16)),
        ),
        child: coverUrl != null
            ? Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _placeholder(isLoading: true);
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder({bool isLoading = false}) {
    return Center(
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              'Cover Buku',
              style: EpicSize.bodyLarge.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
    );
  }
}
