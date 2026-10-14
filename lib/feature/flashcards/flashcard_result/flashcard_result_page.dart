import 'package:epic_story_app/domain/entities/flashcards/flashcard_card_entity.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_result/flashcard_result_controller.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashCardResultPage extends GetView<FlashCardResultController> {
  const FlashCardResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE0CEFF),
      body: SafeArea(
        child: Obx(() {
          final cards = controller.cards;
          final claimedRewards =
              controller.flashcardHistory.value?.claimedRewards ?? [];
          final rewards = controller.flashcard.rewards ?? [];
          final isRewardClaimed = controller.isRewardClaimed.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/hasil-flashcard.png'),
                const SizedBox(height: 10),
                _resultRewardPanel(
                  correctCount: controller.correctCount.value,
                  totalQuiz: controller.totalQuiz.value,
                  isRewardClaimed: isRewardClaimed,
                  onTapReward: controller.goToClaimReward,
                ),
                const SizedBox(height: 18),
                if (cards.isEmpty)
                  _emptyPlaceholder()
                else
                  Column(
                    children: [
                      for (int i = 0; i < cards.length; i += 2) ...[
                        _cardRow(
                          left: cards[i],
                          right: i + 1 < cards.length ? cards[i + 1] : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                if (claimedRewards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _claimedRewardSection(
                    rewards: rewards,
                    claimed: claimedRewards,
                    onTapThumb: (urls, index) {
                      mainController.showRewardPhotoViewer(
                        imageUrls: urls,
                        initialIndex: index,
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _resultRewardPanel({
    required int correctCount,
    required int totalQuiz,
    required bool isRewardClaimed,
    required VoidCallback onTapReward,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: 6,
          child: IgnorePointer(
            child: Container(
              width: 220,
              height: 160,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.85,
                  colors: [Color(0x66FFF3A5), Color(0x00FFF3A5)],
                ),
              ),
            ),
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/icon-get-reward.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: h * 0.55,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        const Text(
                          'Total Kuis',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF08B39),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/icon-perment.png',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$correctCount/$totalQuiz',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEB6E17),
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: w * 0.17,
                    right: w * 0.17,
                    bottom: h * 0.1,
                    child: _RewardPanelButton(
                      isClaimed: isRewardClaimed,
                      onTap: onTapReward,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cardRow(
      {required FlashcardCardEntity left, FlashcardCardEntity? right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _cardTile(left)),
        const SizedBox(width: 14),
        if (right != null)
          Expanded(child: _cardTile(right))
        else
          const Spacer(),
      ],
    );
  }

  Widget _cardTile(FlashcardCardEntity card) {
    final isQuiz = (card.quizType ?? 0) > 0 || card.quiz?.quizData != null;

    return isQuiz
        // ? _cardBox(
        //     const Center(
        //       child: Text(
        //         '?',
        //         style: TextStyle(
        //           fontSize: 34,
        //           fontWeight: FontWeight.w900,
        //           color: Colors.black,
        //         ),
        //       ),
        //     ),
        //   )
        ? SizedBox.shrink()
        : _cardBox(
            Center(
              child: Text(
                card.text ?? 'Show Quiz',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.35,
                ),
              ),
            ),
          );
  }

  Widget _cardBox(Widget child) {
    return AspectRatio(
      aspectRatio: 0.74,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF5EA7FF),
            ],
            stops: [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _claimedRewardSection({
    required List<String> rewards,
    required List<int> claimed,
    required void Function(List<String> urls, int index) onTapThumb,
  }) {
    final urls = claimed
        .where((i) => i >= 0 && i < rewards.length)
        .map((i) => rewards[i])
        .toList();

    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hadiah yang sudah kamu dapatkan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(urls.length, (index) {
            return GestureDetector(
              onTap: () => onTapThumb(urls, index),
              child: SizedBox(
                width: 96,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _rewardThumb(urls[index]),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _rewardThumb(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 22,
          color: Colors.black54,
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _emptyPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Text(
        'Belum ada hasil untuk flashcard ini.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}

class _RewardPanelButton extends StatefulWidget {
  const _RewardPanelButton({required this.isClaimed, required this.onTap});

  final bool isClaimed;
  final VoidCallback onTap;

  @override
  State<_RewardPanelButton> createState() => _RewardPanelButtonState();
}

class _RewardPanelButtonState extends State<_RewardPanelButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _RewardPanelButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isClaimed != widget.isClaimed) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isClaimed) {
      _controller.stop();
      _controller.value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final animation =
        widget.isClaimed ? const AlwaysStoppedAnimation<double>(1) : _scale;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: animation,
        child: SizedBox(
          height: 58,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/bg-button-get-reward.png',
                  fit: BoxFit.fill),
              Center(
                child: Text(
                  widget.isClaimed ? 'Claimed' : 'Reward!!!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
