import 'package:epic_story_app/feature/books/presentation/book_read/book_read_controller.dart';
import 'package:epic_story_app/feature/books/presentation/book_read/components/dialog_add_book_coll.dart';
import 'package:epic_story_app/feature/books/presentation/book_read/components/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

/// PDF reader page driven by controller; no widget parameters (clean architecture).
class BookReadPage extends StatefulWidget {
  const BookReadPage({super.key});

  @override
  State<BookReadPage> createState() => _BookReadPageState();
}

class _BookReadPageState extends State<BookReadPage> {
  final BookReadController controller = Get.find<BookReadController>();

  static const Color _mainBackground = Color(0xFFE0CEFF);
  static const double _topBarHeight = 84;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // PDF content area
            Positioned.fill(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final path = controller.pdfPath.value;
                if (path == null) {
                  if (controller.isPdfLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value != null) {
                    return Center(
                      child: Text(
                        controller.error.value!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      'PDF tidak tersedia',
                      style: TextStyle(color: Colors.black87),
                    ),
                  );
                }
                return _PdfContent(
                  key: ValueKey(path),
                  path: path,
                  controller: controller,
                );
              }),
            ),

            // Top bar: back + actions
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Obx(() {
                final bool isBookVisible = !controller.isLoading.value &&
                    !controller.isPdfLoading.value &&
                    controller.error.value == null &&
                    controller.pdfPath.value != null;

                return Container(
                  height: _topBarHeight,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    gradient: isBookVisible
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF7E32AB),
                              Color(0xFFE0CEFF),
                            ],
                            stops: [0.0, 1.0],
                          ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Get.back<void>(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.42),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.reply_rounded,
                            size: 46,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildTopActionButton(
                            icon: Icons.bookmark,
                            backgroundColor: const Color(0xFFFFED8C),
                            iconColor: const Color(0xFF8D8D8D),
                            onTap: () {
                              if (controller.isLoading.value) {
                                Get.snackbar(
                                  'Collection',
                                  'Tunggu sampai buku selesai dimuat.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2),
                                );
                                return;
                              }
                              showAddBookCollectionSheet(
                                context,
                                controller,
                                controller.book,
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildTopActionButton(
                            icon: controller.isSoundOn.value
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            backgroundColor: const Color(0xFF999999),
                            iconColor: controller.isSoundOn.value
                                ? const Color(0xFFF3D86A)
                                : const Color(0xFFE4E4E4),
                            onTap: controller.toggleSound,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),

            // Bottom controls: prev, indicator, next
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Obx(
                () {
                  final idx = controller.currentIndex.value;
                  final length = controller.totalPages.value;
                  final canGoPrev = idx > 0;
                  final bool isLastPage = length > 0 && idx >= length - 1;
                  final bool hasQuiz =
                      controller.bookHistory.value?.quiz != null;
                  final bool canGoNextPage = length > 0 && !isLastPage;
                  final bool allowQuizNav = isLastPage;
                  final VoidCallback? nextAction = canGoNextPage
                      ? () => controller.goTo(idx + 1)
                      : allowQuizNav
                          ? () {
                              if (hasQuiz) {
                                controller.goToQuizPage();
                              } else {
                                Get.snackbar(
                                  'Quiz',
                                  'Quiz belum tersedia.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            }
                          : null;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavArrowButton(
                        icon: Icons.play_arrow_rounded,
                        onTap:
                            canGoPrev ? () => controller.goTo(idx - 1) : null,
                        isPrevious: true,
                      ),
                      DotsIndicator(
                        length: length,
                        index: idx,
                        activeColor: const Color(0xFFD9D9D9),
                        inactiveColor: const Color(0xFFD9D9D9),
                        activeBorderColor: const Color(0xFF2A2A2A),
                      ),
                      _buildNavArrowButton(
                        icon: Icons.play_arrow_rounded,
                        onTap: nextAction,
                        isPrevious: false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
          ),
          child: Icon(icon, size: 32, color: iconColor),
        ),
      ),
    );
  }

  Widget _buildNavArrowButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrevious,
  }) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFF9CC8F2) : const Color(0xFF66B0FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(isPrevious ? 3.14159 : 0),
            child: Icon(
              icon,
              color:
                  disabled ? const Color(0xFF2F2F2F) : const Color(0xFF161616),
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extracted PDF widget to avoid rebuild when parent Obx re-evaluates.
class _PdfContent extends StatelessWidget {
  const _PdfContent({
    super.key,
    required this.path,
    required this.controller,
  });

  final String path;
  final BookReadController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox.expand(
        child: PDFView(
          filePath: path,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.HEIGHT,
          preventLinkNavigation: true,
          onViewCreated: controller.onPdfViewCreated,
          onRender: (pages) =>
              controller.setTotalPages((pages ?? 0).clamp(0, 10000)),
          onPageChanged: (page, total) {
            if (page != null) controller.onPageChanged(page);
            if (total != null) controller.setTotalPages(total);
          },
        ),
      ),
    );
  }
}
