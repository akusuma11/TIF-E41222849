import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/domain/entities/children_collection_entity.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_entity.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteHomeController extends GetxController {
  var collections = <ChildrenCollectionEntity>[].obs;
  var flashcardCollections = <FlashCardCollectionEntity>[].obs;

  final mainController = Get.find<MainController>();
  final navController = Get.find<EpicNavigationController>();

  var isBook = true.obs;

  final CollectionUsecase collectionUsecase;

  FavoriteHomeController({
    required this.collectionUsecase,
  });

  @override
  void onInit() async {
    super.onInit();
    await refreshData();

    ever(navController.refreshCollectionHome, (value) {
      refreshData(refreshRemote: true);
    });
  }

  Future<void> refreshData({bool refreshRemote = false}) async {
    try {
      EpicLog.debug('Refreshing collections data');
      flashcardCollections.clear();
      if (refreshRemote) {
        await mainController.childrenUsecase.syncChildrenData();
      }
      var children = await mainController.childrenUsecase.getCurrentChildren();
      collections.clear();
      flashcardCollections.clear();
      collections.addAll(children?.collections ?? []);
      flashcardCollections.addAll(children?.flashcardCollections ?? []);
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'refreshData');
    }
  }

  Future<void> onRefresh() async {
    await refreshData(refreshRemote: true);
  }

  Future<bool> _showDeleteConfirmation({
    required String title,
    required String subtitle,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    return result ?? false;
  }

  Future<void> deleteBookCollection(
    ChildrenCollectionEntity data,
  ) async {
    try {
      if (data.id.isEmpty) return;
      final isConfirmed = await _showDeleteConfirmation(
        title: 'Hapus koleksi buku?',
        subtitle: 'Koleksi "${data.title ?? '-'}" akan dihapus permanen.',
      );
      if (!isConfirmed) return;

      await collectionUsecase.removeCollection(
        collectionId: data.id,
      );
      await refreshData(refreshRemote: true);
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'deleteBookCollection');
    }
  }

  Future<void> deleteFlashcardCollection(
    FlashCardCollectionEntity data,
  ) async {
    try {
      if (data.collectionId.isEmpty) return;
      final isConfirmed = await _showDeleteConfirmation(
        title: 'Hapus koleksi flashcard?',
        subtitle: 'Koleksi "${data.title ?? '-'}" akan dihapus permanen.',
      );
      if (!isConfirmed) return;

      await collectionUsecase.removeFlashcardCollection(
        collectionId: data.collectionId,
      );
      await refreshData(refreshRemote: true);
    } catch (ex, s) {
      EpicLog.exception(ex, s, this, 'deleteFlashcardCollection');
    }
  }

  void goToCreateCollection() async {
    await Get.toNamed(
      EpicRoutes.createCollection,
    );
    await refreshData(refreshRemote: true);
  }

  void goToCollectionBookDetail(
    ChildrenCollectionEntity data,
  ) async {
    await Get.toNamed(
      EpicRoutes.detailCollection,
      arguments: data.id,
    );
    await refreshData(refreshRemote: true);
  }

  void goToCollectionFlashcardDetail(
    FlashCardCollectionEntity data,
  ) async {
    await Get.toNamed(
      EpicRoutes.detailCollectionFlashcard,
      arguments: data.collectionId,
    );
    await refreshData(refreshRemote: true);
  }
}
