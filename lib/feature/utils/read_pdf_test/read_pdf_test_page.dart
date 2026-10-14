import 'package:epic_story_app/feature/utils/read_pdf_test/read_pdf_test_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReadPdfTestPage extends StatelessWidget {
  const ReadPdfTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReadPdfTestController>();
    const assetPath = 'assets/books/others/transportation.pdf';

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Page ${controller.currentPage.value}')),
        actions: [
          Obx(() => IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.currentPage.value > 1 ? () => controller.previousPage() : null,
          )),
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => controller.nextPage(),
          ),
          IconButton(
            tooltip: 'First page',
            icon: const Icon(Icons.first_page),
            onPressed: () => controller.jumpToPage(1),
          ),
          // New: print/extract text on current page
          IconButton(
            tooltip: 'Print page text',
            icon: const Icon(Icons.print),
            onPressed: () => controller.printCurrentPageText(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Visible main viewer (single page layout)
            SfPdfViewer.asset(
              assetPath,
              key: controller.viewerKey.value,
              controller: controller.mainPdfController,
              pageLayoutMode: PdfPageLayoutMode.single,
              pageSpacing: 0,
              onPageChanged: (PdfPageChangedDetails details) {
                controller.currentPage.value = details.newPageNumber;
              },
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                // Tidak ada preload, hanya memuat halaman yang terlihat
              },
            ),
          ],
        ),
      ),
    );
  }
}
