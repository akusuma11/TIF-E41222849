import 'package:epic_story_app/feature/favorites/presentation/favorite_home/components/collection_card.dart';
import 'package:epic_story_app/feature/favorites/presentation/favorite_home/favorite_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookCollection extends StatelessWidget {
  final FavoriteHomeController controller;

  const BookCollection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.collections;

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
                  'Belum ada koleksi buku',
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
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) => CollectionCard(
            item: items[index],
            index: index,
            onTap: () {
              controller.goToCollectionBookDetail(items[index]);
            },
            onDelete: () {
              controller.deleteBookCollection(items[index]);
            },
          ),
        ),
      );
    });
  }
}
