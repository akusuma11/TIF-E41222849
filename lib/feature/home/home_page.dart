import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          controller.onBack();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFE0CEFF),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.getState(),
        ),
      ),
    );
  }
}
