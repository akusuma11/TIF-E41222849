import 'package:epic_story_app/feature/home/enums/home_state.dart';
import 'package:flutter/material.dart';
import 'package:epic_story_app/core/widgets/cards/stacked_info_top_bar.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class HomeStateWidget extends StatelessWidget {
  const HomeStateWidget({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  static const Color _mainBackground = Color(0xFFE0CEFF);
  static const Color _bookCardBg = Color(0xFFFFCF25);
  static const Color _flashcardCardBg = Color(0xFF1A6EFC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _mainBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Obx(
              () => StackedInfoTopBar(
                titleText: 'Tipe Belajar',
                infoText: 'Silahkan pilih tipe belajar\nyang kamu mau',
                isBackButtonVisible: controller.state.value != HomeState.home,
                onBackTap: controller.onBack,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 70, 18, 120),
                  child: Column(
                    children: [
                      const Text(
                        'Pilih Tipe Belajar Kamu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              color: Color(0x40000000),
                              offset: Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      _buildBookCard(),
                      const SizedBox(height: 24),
                      _buildFlashcardCard(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard() {
    return GestureDetector(
      onTap: () {
        controller.navController.isBook.value = true;
        controller.state.value = HomeState.category;
      },
      child: Container(
        width: double.infinity,
        height: 142,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: _bookCardBg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/tipe-book.png',
              width: 128,
              height: 128,
            ),
            const SizedBox(width: 8), // atur jarak di sini
            const Text(
              'Buku',
              style: TextStyle(
                color: Colors.black,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardCard() {
    return GestureDetector(
      onTap: () {
        controller.navController.isBook.value = false;
        controller.state.value = HomeState.category;
      },
      child: Container(
        width: double.infinity,
        height: 142,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: _flashcardCardBg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/tipe-flashcard.png',
              width: 168,
              height: 82,
            ),
            const SizedBox(height: 2),
            const Text(
              'Flashcard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
