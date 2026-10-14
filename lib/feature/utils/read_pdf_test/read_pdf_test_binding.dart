import 'package:get/get.dart';

import 'read_pdf_test_controller.dart';

class ReadPdfTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReadPdfTestController>(() => ReadPdfTestController());
  }
}