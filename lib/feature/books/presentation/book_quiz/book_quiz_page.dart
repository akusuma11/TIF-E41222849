import 'package:epic_story_app/core/styles/epic_box_colors.dart';
import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/core/widgets/cards/box_shadow.dart';
import 'package:epic_story_app/feature/books/presentation/book_quiz/book_quiz_controller.dart';
import 'package:epic_story_app/feature/books/presentation/book_quiz/components/quiz/fill_blank_quiz.dart';
import 'package:epic_story_app/feature/books/presentation/book_quiz/components/quiz/group_quiz.dart';
import 'package:epic_story_app/feature/books/presentation/book_quiz/components/quiz/multiple_choice_quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BookQuizPage extends StatefulWidget {
  const BookQuizPage({super.key});

  @override
  State<BookQuizPage> createState() => _BookQuizPageState();
}

class _BookQuizPageState extends State<BookQuizPage> {
  final BookQuizController controller = Get.find<BookQuizController>();

  void _handleBackTap() {
    if (controller.isLoading.value) {
      Get.snackbar(
        'Quiz',
        'Tunggu proses generate selesai.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    controller.closePage();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EpicAppSize.initialize(context);
    var width = EpicAppSize.screenWidth;
    var height = EpicAppSize.screenHeight;
    return Scaffold(
      backgroundColor: const Color(0xFFE0CEFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE0CEFF),
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 78,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: Obx(
            () => _BookQuizTopBar(
              title: controller.title.value,
              onBackTap: _handleBackTap,
            ),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _handleBackTap();
          return false;
        },
        child: Obx(
          () => Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ShadowBox(
                  width: width * 0.9,
                  height: height * 0.75,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  cardColor: BoxColors.purplePrimary,
                  radius: BorderRadius.circular(
                    EpicAppSize.calculatedSize(24),
                  ),
                  child: _buildQuizBody(),
                ),
                if (controller.isQuizAvailable)
                  Positioned(
                    bottom: EpicAppSize.calculatedSize(-20),
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildCheckButton(context),
                    ),
                  ),
                if (controller.isQuizAvailable)
                  Positioned(
                    top: -20,
                    right: 16,
                    child: _buildOverlayControl(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizBody() {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (!controller.isQuizAvailable) {
      return const Center(
        child: Text(
          'Quiz belum tersedia untuk buku ini.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildQuizWidgetByType(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizWidgetByType() {
    if (controller.quizType == 1 && controller.multipleChoiceQuiz != null) {
      return BookMultipleChoiceQuiz(
        quizController: controller,
        quizData: controller.multipleChoiceQuiz!,
      );
    }

    if (controller.quizType == 2 && controller.fillBlankQuiz != null) {
      return BookFillBlankQuiz(
        quizController: controller,
        quizData: controller.fillBlankQuiz!,
      );
    }

    if (controller.quizType == 3 && controller.groupQuiz != null) {
      return BookGroupQuiz(
        quizController: controller,
        quizData: controller.groupQuiz!,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCheckButton(BuildContext context) {
    if (controller.isLoading.value) {
      return const SizedBox.shrink();
    }

    final isRewardUnclaimed =
        controller.bookHistory.value?.claimedRewards == null ||
            controller.bookHistory.value!.claimedRewards!.isEmpty;

    if (controller.isAnswerCorrect.value) {
      if (isRewardUnclaimed) {
        return _PulsingRewardShadowButton(
          onTap: controller.openBookRewardClaim,
          width: MediaQuery.of(context).size.width * 0.65,
          height: EpicAppSize.calculatedSize(50),
        );
      }

      return ShadowBox(
        cardColor: BoxColors.bluePrimary,
        isCanClick: false,
        width: MediaQuery.of(context).size.width * 0.65,
        height: EpicAppSize.calculatedSize(50),
        borderWidthRatio: EpicAppSize.borderWidthRatio,
        radius: BorderRadius.circular(EpicAppSize.calculatedSize(50)),
        child: Center(
          child: Text(
            'Kuis Sudah Diselesaikan',
            style: TextStyle(
              color: BoxColors.bluePrimary.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final isCanAnswer = (controller.retryQuestion.value > 0) &&
        controller.isAnswerCorrect.value == false;
    final bgColor =
        isCanAnswer ? BoxColors.greenSecondary : BoxColors.grayDisabled;

    return ShadowBox(
      cardColor: bgColor,
      isCanClick: isCanAnswer,
      onTap: controller.onCheckAnswer,
      width: MediaQuery.of(context).size.width * 0.65,
      height: EpicAppSize.calculatedSize(50),
      borderWidthRatio: EpicAppSize.borderWidthRatio,
      radius: BorderRadius.circular(EpicAppSize.calculatedSize(50)),
      child: Center(
        child: Text(
          'Cek Jawaban',
          style: TextStyle(
            color: bgColor.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayControl() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox();
      }

      final isCorrect = controller.isAnswerCorrect.value;
      final explanation = controller.explanation;

      if (isCorrect) {
        return _buildHelpButton(explanation);
      }

      final retries = controller.retryQuestion.value;
      if (retries <= 0) {
        return Row(
          children: [
            _PulsingRetryButton(
              onPressed: () {
                controller.forceGenerateQuiz();
              },
            ),
            const SizedBox(width: 8),
            _buildHelpButton(explanation),
          ],
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BoxColors.purplePrimary.backgroundColor,
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final filled = retries > index;
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
              child: Icon(
                filled ? Icons.favorite : Icons.favorite_border,
                size: 30,
                color: filled ? Colors.pink : BoxColors.purplePrimary.textColor,
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildHelpButton(String? explanation) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          // Visibility(
          //   visible: controller.bookHistory.value?.claimedRewards == null ||
          //       controller.bookHistory.value!.claimedRewards!.isEmpty,
          //   child: GestureDetector(
          //     onTap: () {
          //       controller.openBookRewardClaim();
          //     },
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 10,
          //         vertical: 6,
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(14),
          //         border: Border.all(
          //           color: BoxColors.purplePrimary.backgroundColor,
          //           width: 1.1,
          //         ),
          //       ),
          //       child: Text(
          //         'Dapatkan Hadiah',
          //         style: TextStyle(
          //           color: BoxColors.purplePrimary.textColor,
          //           fontSize: 14,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.showExplanationDialog(explanation),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BoxColors.purplePrimary.backgroundColor,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.help_outline,
                size: 22,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookQuizTopBar extends StatelessWidget {
  const _BookQuizTopBar({
    required this.title,
    required this.onBackTap,
  });

  final String title;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TopBackButton(onTap: onBackTap),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 55,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/judul-kartu.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            title.isEmpty ? 'Quiz' : title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.white,
                              height: 1,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
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
        const SizedBox(width: 10),
      ],
    );
  }
}

class _TopBackButton extends StatelessWidget {
  const _TopBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 21,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _PulsingRetryButton extends StatefulWidget {
  const _PulsingRetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_PulsingRetryButton> createState() => _PulsingRetryButtonState();
}

class _PulsingRetryButtonState extends State<_PulsingRetryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: BoxColors.purplePrimary.textColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(
            color: BoxColors.purplePrimary.backgroundColor,
            width: 1.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: widget.onPressed,
        child: const Text(
          'Coba Lagi',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PulsingRewardShadowButton extends StatefulWidget {
  const _PulsingRewardShadowButton({
    required this.onTap,
    required this.width,
    required this.height,
  });

  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  State<_PulsingRewardShadowButton> createState() =>
      _PulsingRewardShadowButtonState();
}

class _PulsingRewardShadowButtonState extends State<_PulsingRewardShadowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ShadowBox(
        cardColor: BoxColors.yellowPrimary,
        isCanClick: true,
        onTap: widget.onTap,
        width: widget.width,
        height: widget.height,
        borderWidthRatio: EpicAppSize.borderWidthRatio,
        radius: BorderRadius.circular(EpicAppSize.calculatedSize(50)),
        child: Center(
          child: Text(
            'Dapatkan Hadiah',
            style: TextStyle(
              color: BoxColors.yellowPrimary.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
