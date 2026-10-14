import 'package:epic_story_app/core/utils/epic_log.dart';
import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/domain/entities/children_collection_entity.dart';
import 'package:epic_story_app/domain/entities/collections/flashcard_collection_entity.dart';
import 'package:epic_story_app/domain/usecases/collection_usecase.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/favorites/presentation/create_collection/create_collection_args.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCollectionController extends GetxController {
  final CollectionUsecase collectionUsecase;

  CreateCollectionController({
    required this.collectionUsecase,
  });

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  final mainController = Get.find<MainController>();

  final types = const ['Buku', 'Flashcard'];
  final RxString selectedType = ''.obs;

  final List<CollectionColorModel> palette = kCollectionColorPalette;

  final RxInt selectedIndex = (-1).obs;
  final RxBool isSaving = false.obs;
  final RxBool isEditMode = false.obs;
  String? editingCollectionId;

  CollectionColorModel? get selectedColorModel =>
      selectedIndex.value >= 0 ? palette[selectedIndex.value] : null;

  Color? get selectedColor => selectedColorModel?.color;

  LinearGradient? get selectedGradient => selectedColorModel?.gradient;

  @override
  void onInit() {
    super.onInit();
    _loadArgs();
  }

  void _loadArgs() {
    final args = Get.arguments;
    if (args is! CreateCollectionArgs || !args.isEdit) return;

    isEditMode.value = true;
    editingCollectionId = args.collectionId;
    selectedType.value = args.type;
    nameCtrl.text = args.title ?? '';
    descCtrl.text = args.desc ?? '';

    final colorIndex = args.bgColor;
    if (colorIndex != null && colorIndex >= 0 && colorIndex < palette.length) {
      selectedIndex.value = colorIndex;
    }
  }

  Future<void> onSubmit() async {
    final title = nameCtrl.text.trim();
    final desc = descCtrl.text.trim();
    final colorIndex = selectedIndex.value;
    final type = selectedType.value;

    if (title.isEmpty) {
      Get.snackbar('Gagal', 'Nama koleksi tidak boleh kosong');
      return;
    }
    if (colorIndex < 0 || colorIndex >= palette.length) {
      Get.snackbar('Gagal', 'Pilih warna background terlebih dahulu');
      return;
    }
    if (type.isEmpty) {
      Get.snackbar('Gagal', 'Pilih tipe koleksi');
      return;
    }

    isSaving.value = true;
    final now = DateTime.now();
    final generatedId = now.millisecondsSinceEpoch.toString();

    EpicLog.debug("type selected: ${selectedType.value}");

    try {
      mainController.showLoadingPage();
      if (isEditMode.value) {
        final collectionId = editingCollectionId;
        if (collectionId == null || collectionId.isEmpty) {
          Get.snackbar('Gagal', 'Koleksi tidak ditemukan');
          return;
        }

        if (type == 'Buku') {
          final updatedCollection = ChildrenCollectionEntity(
            id: collectionId,
            bgColor: colorIndex,
            title: title,
            desc: desc.isEmpty ? null : desc,
            updatedAt: now,
          );
          await collectionUsecase.updateCollection(
            collection: updatedCollection,
          );
        } else {
          final updatedCollection = FlashCardCollectionEntity(
            collectionId: collectionId,
            title: title,
            desc: desc.isEmpty ? null : desc,
            bgColor: colorIndex,
            updatedAt: now,
          );
          await collectionUsecase.updateFlashcardCollection(
            collection: updatedCollection,
          );
        }
        mainController.hideLoadingPage();
        Get.back(result: true);
        Get.snackbar('Berhasil', 'Koleksi berhasil diperbarui');
        return;
      }

      if (selectedType.value == 'Buku') {
        final bookCollection = ChildrenCollectionEntity(
          id: generatedId,
          bgColor: colorIndex,
          title: title,
          desc: desc.isEmpty ? null : desc,
          nBooks: 0,
          nPages: 0,
          bookCovers: const [],
          categories: const [],
          createdAt: now,
          updatedAt: now,
        );
        await collectionUsecase.createCollection(collection: bookCollection);
      } else {
        var flashcardCollection = FlashCardCollectionEntity(
          collectionId: generatedId,
          title: title,
          desc: desc.isEmpty ? null : desc,
          bgColor: colorIndex,
          categories: const [],
          totalCards: 0,
          totalFlashcard: 0,
          totalQuiz: 0,
          completedQuiz: 0,
          createdAt: now,
          updatedAt: now,
        );
        await collectionUsecase.createFlashcardCollection(
          collection: flashcardCollection,
        );
      }
      mainController.hideLoadingPage();
      Get.back(result: true);
      Get.snackbar('Berhasil', 'Koleksi berhasil dibuat');
    } catch (e) {
      Get.snackbar(
        'Gagal',
        isEditMode.value
            ? 'Tidak dapat memperbarui koleksi'
            : 'Tidak dapat membuat koleksi',
      );
    } finally {
      isSaving.value = false;
      mainController.hideLoadingPage();
    }
  }

  void selectColor(int index) {
    selectedIndex.value = index;
  }

  void selectType(String? value) {
    if (value != null) selectedType.value = value;
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }
}
