import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/core/widgets/cards/stacked_info_top_bar.dart';
import 'package:epic_story_app/data/models/remotes/collection_color_model.dart';
import 'package:epic_story_app/feature/favorites/presentation/create_collection/create_collection_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCollectionPage extends StatefulWidget {
  const CreateCollectionPage({super.key});

  @override
  State<CreateCollectionPage> createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  late final CreateCollectionController controller =
      Get.find<CreateCollectionController>();

  static const Color _pageBackground = Color(0xFFC6B2E6);
  static const Color _inputBorder = Color(0xFF22162F);
  static const Color _saveButton = Color(0xFF8BDE88);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Obx(() {
              final isEditMode = controller.isEditMode.value;
              return StackedInfoTopBar(
                titleText: isEditMode ? 'Edit Koleksi' : 'Buat Koleksi',
                infoText: isEditMode
                    ? 'Silahkan ubah koleksi yang\nsudah kamu buat sebelumnya'
                    : 'Silahkan buat koleksi dari\nbuku/flashcard yang ingin\nkamu pelajari selanjutnya',
                isBackButtonVisible: true,
                onBackTap: () => Get.back(),
              );
            }),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  EpicSize.calculatedSize(30),
                  EpicSize.calculatedSize(10),
                  EpicSize.calculatedSize(30),
                  EpicSize.calculatedSize(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: EpicAppSize.calculatedSize(16),
                    ),
                    _FieldLabel(text: 'Nama Koleksi'),
                    SizedBox(
                      height: EpicAppSize.calculatedSize(10),
                    ),
                    TextField(
                      controller: controller.nameCtrl,
                      decoration: _inputDecoration(),
                    ),
                    SizedBox(
                      height: EpicAppSize.calculatedSize(16),
                    ),
                    _FieldLabel(text: 'Tipe Koleksi'),
                    SizedBox(
                      height: EpicAppSize.calculatedSize(10),
                    ),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedType.value.isEmpty
                            ? null
                            : controller.selectedType.value,
                        hint: const Text(
                          'Pilih satu (dropdown)',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        items: controller.types
                            .map(
                              (t) => DropdownMenuItem<String>(
                                value: t,
                                child: Text(t),
                              ),
                            )
                            .toList(),
                        onChanged: controller.isEditMode.value
                            ? null
                            : controller.selectType,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration(),
                        isExpanded: true,
                        dropdownColor: _pageBackground,
                      ),
                    ),
                    SizedBox(height: EpicAppSize.calculatedSize(20)),
                    _FieldLabel(text: 'Deskripsi Koleksi'),
                    SizedBox(height: EpicAppSize.calculatedSize(10)),
                    TextField(
                      controller: controller.descCtrl,
                      decoration: _inputDecoration(),
                      minLines: 5,
                      maxLines: 5,
                    ),
                    SizedBox(height: EpicAppSize.calculatedSize(22)),
                    _FieldLabel(text: 'Background Koleksi'),
                    SizedBox(height: EpicAppSize.calculatedSize(10)),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final spacing = EpicSize.calculatedSize(18);

                        return GridView.builder(
                          shrinkWrap: true,
                          itemCount: controller.palette.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final colorModel = controller.palette[index];
                            return Obx(
                              () {
                                final selected =
                                    controller.selectedIndex.value == index;
                                return GestureDetector(
                                  onTap: () => controller.selectColor(index),
                                  child: _ColorSwatch(
                                    colorModel: colorModel,
                                    selected: selected,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: EpicSize.calculatedSize(32)),
                    Obx(
                      () => controller.isSaving.value
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: EpicSize.sizeSmall),
                    Center(
                      child: GestureDetector(
                        onTap: controller.onSubmit,
                        child: Container(
                          width: EpicSize.calculatedSize(220),
                          height: EpicSize.calculatedSize(52),
                          decoration: BoxDecoration(
                            color: _saveButton,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1A9E1A),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x3F000000),
                                offset: Offset(0, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: EpicAppSize.calculatedSize(22),
                                fontWeight: FontWeight.w900,
                                height: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        horizontal: EpicSize.sizeSmallMedium,
        vertical: EpicSize.sizeSmall,
      ),
      filled: true,
      fillColor: Colors.transparent,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _inputBorder, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF120D1A),
        fontSize: EpicAppSize.calculatedSize(24),
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final CollectionColorModel colorModel;
  final bool selected;

  const _ColorSwatch({required this.colorModel, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: EpicAppSize.calculatedSize(45),
      height: EpicAppSize.calculatedSize(45),
      decoration: BoxDecoration(
        gradient: colorModel.gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? Colors.black : Colors.black26,
          width: selected ? 2.5 : 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colorModel.color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
    );
  }
}
