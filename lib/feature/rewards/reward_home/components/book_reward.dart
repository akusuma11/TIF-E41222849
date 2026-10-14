import 'package:epic_story_app/domain/entities/book_entity.dart';
import 'package:epic_story_app/domain/entities/book_histories_entity.dart';
import 'package:epic_story_app/feature/others/main_controller/main_controller.dart';
import 'package:epic_story_app/feature/rewards/reward_home/components/reward_claim_button.dart';
import 'package:epic_story_app/feature/rewards/reward_home/reward_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookReward extends StatelessWidget {
  const BookReward({super.key, required this.controller});

  final RewardHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final books = controller.books;
      if (books.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Text(
                'Belum ada hadiah buku yang tersedia.',
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
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = books[index];
          final history = controller.historyForBook(book.bookId);
          return GestureDetector(
            onTap: () => controller.goToBookRead(book),
            child: _BookRewardCard(
              itemIndex: index,
              book: book,
              history: history,
              onClaim: () => controller.openBookRewardClaim(book),
            ),
          );
        },
      );
    });
  }
}

class _BookRewardCard extends StatefulWidget {
  const _BookRewardCard({
    required this.itemIndex,
    required this.book,
    required this.history,
    required this.onClaim,
  });

  final int itemIndex;
  final BookEntity book;
  final BookHistoryEntity? history;
  final VoidCallback onClaim;

  @override
  State<_BookRewardCard> createState() => _BookRewardCardState();
}

class _BookRewardCardState extends State<_BookRewardCard>
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
      _btnScaleController.value = 0.5;
      _animating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final history = widget.history;
    final isColorOne = widget.itemIndex.isEven;

    final title = history?.title ?? book.title ?? 'Judul Buku';
    final summary = book.summary ?? '-';
    final category = history?.category ?? book.category ?? '-';
    final totalPages = history?.totalPages ?? book.totalPages ?? 0;
    final isFinished = history?.isFinished == true;
    final isClaimed = (history?.claimedRewards?.isNotEmpty ?? false);

    final rewardImages = book.rewards ?? [];
    final rewardsClaimed = history?.claimedRewards ?? [];
    final claimedThumbs = rewardsClaimed
        .where((i) => i >= 0 && i < rewardImages.length)
        .map((i) => rewardImages[i])
        .take(3)
        .toList();

    final shouldAnimateButton = !isClaimed && isFinished;
    _syncButtonAnimation(shouldAnimateButton);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isColorOne
              ? const [Color(0xFFFFDAA0), Color(0xFFFFFFFF)]
              : const [Color(0xFFAAFFC0), Color(0xFFFFFFFF)],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.6), width: 1.1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BookCover(url: history?.bookCover ?? book.bookCover),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category : $category',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total Halaman : $totalPages',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
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
                isClaimed ? 'Hadiah sudah diklaim' : 'Hadiah belum diklaim',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                isClaimed
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

class _BookCover extends StatelessWidget {
  const _BookCover({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.6), width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: url == null
            ? const Center(
                child: Text(
                  'Cover Buku',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child:
                      Icon(Icons.broken_image_outlined, color: Colors.black54),
                ),
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
