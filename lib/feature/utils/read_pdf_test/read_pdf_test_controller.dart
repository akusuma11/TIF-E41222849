import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ReadPdfTestController extends GetxController {
  // Visible viewer controller
  final PdfViewerController mainPdfController = PdfViewerController();

  // Key to force rebuilding the SfPdfViewer when switching source (kept if needed)
  final Rx<UniqueKey> viewerKey = UniqueKey().obs;

  // Current page (reactive)
  final RxInt currentPage = 1.obs;

  // New: store extracted text for current page
  final RxString currentPageText = ''.obs;

  // In-memory PDF bytes (raw file) - optional for future use
  Uint8List? preloadedBytes;
  final RxBool isPreloaded = false.obs;

  // Preloading state (loading raw bytes)
  final RxBool isPreloading = false.obs;

  // Flutter TTS instance
  final FlutterTts _flutterTts = FlutterTts();

  // Optional: track speaking state
  final RxBool isSpeaking = false.obs;

  // Helper to jump to a specific page on the main viewer
  void jumpToPage(int page) {
    try {
      mainPdfController.jumpToPage(page);
    } catch (_) {}
  }

  // Helper to go to next page on the main viewer
  void nextPage() {
    try {
      mainPdfController.nextPage();
    } catch (_) {}
  }

  // Helper to go to previous page on the main viewer
  void previousPage() {
    try {
      mainPdfController.previousPage();
    } catch (_) {}
  }

  // Loads raw bytes from assets (keeps for fallback)
  Future<void> preloadRawBytes() async {
    if (isPreloaded.value || isPreloading.value) return;
    isPreloading.value = true;
    try {
      final data = await rootBundle.load('assets/books/others/transportation.pdf');
      preloadedBytes = data.buffer.asUint8List();
      isPreloaded.value = true;
    } catch (e) {
      isPreloaded.value = false;
    } finally {
      isPreloading.value = false;
    }
  }

  // Extract text for a 1-based page number. Returns null on failure.
  Future<String?> extractTextFromPage(int pageNumber) async {
    if (pageNumber < 1) return null;
    if (preloadedBytes == null) {
      await preloadRawBytes();
    }
    if (preloadedBytes == null) return null;
    PdfDocument? doc;
    try {
      doc = PdfDocument(inputBytes: preloadedBytes!);
      // PdfTextExtractor supports extracting by page index (0-based).
      final extractor = PdfTextExtractor(doc);
      // Attempt to extract just that page
      String text;
      try {
        text = extractor.extractText(startPageIndex: pageNumber - 1, endPageIndex: pageNumber - 1);
      } catch (_) {
        // Fallback: extract whole document and try to approximate
        text = extractor.extractText();
      }
      return text;
    } catch (e) {
      return null;
    } finally {
      try {
        doc?.dispose();
      } catch (_) {}
    }
  }

  // Print current page text to console and save to variable (no dialog)
  Future<void> printCurrentPageText() async {
    final page = currentPage.value;
    final text = await extractTextFromPage(page);

    // Collapse all whitespace (newlines/tabs/multiple spaces) into single spaces
    final cleaned = (text == null || text.trim().isEmpty)
        ? ''
        : text.replaceAll(RegExp(r'\s+'), ' ').trim();

    final output = cleaned.isEmpty ? 'No text found on page $page.' : cleaned;

    // Save the whole-page text (one line) to the reactive variable
    currentPageText.value = output;
    // speak the cleaned page text (skip if no real text)
    if (cleaned.isNotEmpty) {
      await speakText(cleaned);
    }

    // Print to console only
    // ignore: avoid_print
    print('PDF page $page text:\n$output');
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize TTS settings; adjust language/rate/pitch as needed
    () async {
      try {
        await _flutterTts.setLanguage('id-ID'); // or 'en-US'
        await _flutterTts.setSpeechRate(0.45);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);
        // Optional: set handlers
        _flutterTts.setStartHandler(() {
          isSpeaking.value = true;
        });
        _flutterTts.setCompletionHandler(() {
          isSpeaking.value = false;
        });
        _flutterTts.setErrorHandler((msg) {
          isSpeaking.value = false;
        });
      } catch (_) {}
    }();
  }

  // Speak given text using flutter_tts
  Future<void> speakText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      // stop any current speech, then speak
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  @override
  void onClose() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    try {
      mainPdfController.dispose();
    } catch (_) {}
    preloadedBytes = null;
    super.onClose();
  }
}