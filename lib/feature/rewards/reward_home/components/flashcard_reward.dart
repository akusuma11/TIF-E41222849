import 'package:epic_story_app/domain/entities/flashcards/flashcard_entity.dart';
import 'package:epic_story_app/domain/entities/flashcards/flashcard_history_entity.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/rewards/reward_home/components/reward_claim_button.dart';
import 'package:epic_story_app/feature/rewards/reward_home/reward_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashcardReward extends StatelessWidget {
  const FlashcardReward({super.key, required this.controller});

  final RewardHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final cards = controller.flashcards;
      if (cards.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Text(
                'Belum ada hadiah yang tersedia.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final flashcard = cards[index];
          final history = controller.historyFor(flashcard.flashcardId);
          return GestureDetector(
            onTap: () {
              controller.goToFlashcardRead(flashcard);
            },
            child: _RewardCard(
              itemIndex: index,
              flashcard: flashcard,
              history: history,
              onClaim: () => controller.openRewardClaim(flashcard),
            ),
          );
        },
      );
    });
  }
}

class _RewardCard extends StatefulWidget {
  const _RewardCard({
    required this.itemIndex,
    required this.flashcard,
    required this.history,
    required this.onClaim,
  });

  final int itemIndex;
  final FlashcardEntity flashcard;
  final FlashcardHistoryEntity? history;
  final VoidCallback onClaim;

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard>
    with SingleTickerProviderStateMixin {
  final MainController mainController = Get.find<MainController>();

  late final AnimationController _btnScaleController;
  late final Animation<double> _btnScale;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _btnScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _btnScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _btnScaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _btnScaleController.dispose();
    super.dispose();
  }

  void _syncButtonAnimation(bool shouldAnimate) {
    if (shouldAnimate && !_animating) {
      _btnScaleController.repeat(reverse: true);
      _animating = true;
    } else if (!shouldAnimate && _animating) {
      _btnScaleController.stop();
      _btnScaleController.value = 0.5; // center at scale ~1.0
      _animating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = widget.flashcard;
    final history = widget.history;
    final isColorOne = widget.itemIndex.isEven;

    final title = flashcard.title ?? 'Judul Flashcard';
    final summary = flashcard.summary ?? '';
    final category = flashcard.category ?? '-';
    final totalCards = flashcard.totalCards ?? 0;
    final totalQuiz = history?.totalQuiz ?? flashcard.totalQuiz ?? 0;
    final completedQuiz = history?.completedQuiz ?? 0;
    final claimed = (history?.claimedRewards?.isNotEmpty ?? false);
    final rewards = flashcard.rewards ?? [];
    final rewardsClaimed = history?.claimedRewards ?? [];
    final claimedThumbs = rewardsClaimed
        .where((i) => i >= 0 && i < rewards.length)
        .map((i) => rewards[i])
        .take(3)
        .toList();
    final isFinished = history?.isFinished == true;

    final shouldAnimateButton = !claimed && isFinished;
    _syncButtonAnimation(shouldAnimateButton);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isColorOne
              ? const [Color(0xFFFFE588), Color(0xFFFFFFFF)]
              : const [Color(0xFF4EFF4F), Color(0xFFFFFFFF)],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.6), width: 1.1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Chip(label: '$totalCards kartu'),
              _Chip(label: '$completedQuiz/$totalQuiz'),
              _Chip(label: category),
            ],
          ),
          const SizedBox(height: 12),
          if (claimedThumbs.isNotEmpty)
            Row(
              children: List.generate(claimedThumbs.length, (i) {
                final isLast = i == claimedThumbs.length - 1;
                return Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 10),
                  child: _Thumb(
                    url: claimedThumbs[i],
                    onTap: () {
                      mainController.showRewardPhotoViewer(
                        imageUrls: claimedThumbs,
                        initialIndex: i,
                      );
                    },
                  ),
                );
              }),
            ),
          if (shouldAnimateButton) ...[
            const SizedBox(height: 3),
            ScaleTransition(
              scale: _btnScale,
              child: RewardClaimButton(onPressed: widget.onClaim),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                claimed ? 'Hadiah sudah diklaim' : 'Hadiah belum diklaim',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                claimed
                    ? 'assets/images/reward-claimed.png'
                    : 'assets/images/reward-not-claimed.png',
                width: 16,
                height: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.onTap});
  final String? url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.black.withOpacity(0.6), width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: url == null
                ? const Icon(Icons.image_outlined, color: Colors.black54)
                : Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.black54,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
