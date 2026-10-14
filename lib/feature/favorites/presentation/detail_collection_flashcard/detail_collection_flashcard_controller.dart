import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_detail_entity.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_detail_item_entity.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/domain/usecases/flashcard_usecase.dart';
import 'package:epic_story_app/feature/favorites/presentation/create_collection/create_collection_args.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailCollectionFlashcardController extends GetxController {
  var collectionId = ''.obs;
  var collectionDetail = Rx<FlashcardCollectionDetailEntity?>(null);

  var loading = false.obs;

  final CollectionUsecase collectionUsecase;
  final FlashCardUsecase flashCardUsecase;

  DetailCollectionFlashcardController({
    required this.collectionUsecase,
    required this.flashCardUsecase,
  });

  @override
  void onInit() async {
    super.onInit();
    collectionId.value = Get.arguments;
    await _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      loading.value = true;
      final detail = await collectionUsecase.getFlashcardCollectionDetail(
        collectionId: collectionId.value,
      );
      collectionDetail.value = detail;
    } catch (e, s) {
      EpicLog.exception(e, s, this, '_loadDetail');
    } finally {
      loading.value = false;
    }
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

  Future<void> deleteBookFromCollection(
      FlashCardCollectionDetailItemEntity flashcard) async {
    final isConfirmed = await _showDeleteConfirmation(
      title: 'Hapus flashcard dari koleksi?',
      subtitle:
          'Flashcard "${flashcard.title ?? '-'}" akan dihapus dari koleksi ini.',
    );
    if (!isConfirmed) return;

    try {
      loading.value = true;
      await collectionUsecase.removeFlashcardFromCollection(
        collectionId: collectionId.value,
        flashcardId: flashcard.flashcardId!,
      );
      await _loadDetail();
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'deleteBookFromCollection');
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteCollection() async {
    final detail = collectionDetail.value;
    final id = detail?.flashcardId ?? collectionId.value;
    if (id.isEmpty) return;

    final isConfirmed = await _showDeleteConfirmation(
      title: 'Hapus koleksi flashcard?',
      subtitle: 'Koleksi "${detail?.title ?? '-'}" akan dihapus permanen.',
    );
    if (!isConfirmed) return;

    try {
      loading.value = true;
      await collectionUsecase.removeFlashcardCollection(
        collectionId: id,
      );
      loading.value = false;
      Get.back(result: true);
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'deleteCollection');
      loading.value = false;
    }
  }

  Future<void> goToEditCollection() async {
    final detail = collectionDetail.value;
    final id = detail?.flashcardId ?? collectionId.value;
    if (id.isEmpty) return;

    final result = await Get.toNamed(
      EpicRoutes.createCollection,
      arguments: CreateCollectionArgs.edit(
        type: 'Flashcard',
        collectionId: id,
        title: detail?.title,
        desc: detail?.desc,
        bgColor: detail?.bgColor,
      ),
    );

    if (result == true) {
      await _loadDetail();
    }
  }

  Future<void> goToFlashcardRead({
    required String flashcardId,
  }) async {
    try {
      loading.value = true;
      final flashcard = await flashCardUsecase.getFlashcardById(
        flashcardId: flashcardId,
      );
      if (flashcard != null) {
        Get.toNamed(EpicRoutes.flashCardRead, arguments: flashcard);
      } else {
        EpicSnackBar.showWarningSnackBar("Warning", "Flashcard not found");
      }
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'goToFlashcardRead');
    } finally {
      loading.value = false;
    }
  }
}
