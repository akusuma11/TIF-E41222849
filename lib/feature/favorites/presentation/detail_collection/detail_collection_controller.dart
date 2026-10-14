import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/core/utils/epic_snackbar.dart';
import 'package:epic_story_app/domain/entities/collection_book_entity.dart';
import 'package:epic_story_app/domain/entities/collection_detail_entity.dart';
import 'package:epic_story_app/domain/usecases/book_usecase.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/favorites/presentation/create_collection/create_collection_args.dart';
import 'package:epic_story_app/core/routes/epic_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailCollectionController extends GetxController {
  var collectionId = ''.obs;
  var collectionDetail = Rx<CollectionDetailEntity?>(null);

  var loading = false.obs;

  final CollectionUsecase collectionUsecase;
  final BookUsecase bookUsecase;

  DetailCollectionController({
    required this.collectionUsecase,
    required this.bookUsecase,
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
      final detail = await collectionUsecase.getCollectionDetail(
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

  Future<void> deleteBookFromCollection(CollectionBookEntity book) async {
    final isConfirmed = await _showDeleteConfirmation(
      title: 'Hapus buku dari koleksi?',
      subtitle: 'Buku "${book.title ?? '-'}" akan dihapus dari koleksi ini.',
    );
    if (!isConfirmed) return;

    try {
      loading.value = true;
      await collectionUsecase.removeBookFromCollection(
        collectionId: collectionId.value,
        bookId: book.id,
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
    if (detail == null || detail.id.isEmpty) return;

    final isConfirmed = await _showDeleteConfirmation(
      title: 'Hapus koleksi buku?',
      subtitle: 'Koleksi "${detail.title ?? '-'}" akan dihapus permanen.',
    );
    if (!isConfirmed) return;

    try {
      loading.value = true;
      await collectionUsecase.removeCollection(
        collectionId: detail.id,
      );
      loading.value = false;
      Get.back(result: true);
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'deleteCollection');
      loading.value = false;
    }
  }

  Future<void> goToBookRead(CollectionBookEntity book) async {
    try {
      loading.value = true;
      final bookEntity = await bookUsecase.getBookById(bookId: book.id);
      if (bookEntity != null) {
        Get.toNamed(EpicRoutes.bookRead, arguments: bookEntity);
      } else {
        EpicSnackBar.showWarningSnackBar('Warning', 'Buku tidak ditemukan');
      }
    } catch (e, s) {
      EpicLog.exception(e, s, this, 'goToBookRead');
    } finally {
      loading.value = false;
    }
  }

  Future<void> goToEditCollection() async {
    final detail = collectionDetail.value;
    if (detail == null) return;

    final result = await Get.toNamed(
      EpicRoutes.createCollection,
      arguments: CreateCollectionArgs.edit(
        type: 'Buku',
        collectionId: detail.id,
        title: detail.title,
        desc: detail.desc,
        bgColor: detail.bgColor,
      ),
    );

    if (result == true) {
      await _loadDetail();
    }
  }
}
