import 'package:epic_story_app/feature/flashcards/flashcard_reward/flashcard_reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlashcardRewardPage extends GetView<FlashcardRewardController> {
  const FlashcardRewardPage({super.key});

  static const Color _pageBackground = Color(0xFFE0CEFF);
  static const Color _contentBackground = Color(0xFFA991D2);
  static const Color _scrollbarColor = Color(0xFFCACACA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      // appBar: const CustomAppBar(title: 'Dapatkan Reward'),
      body: Obx(
        () {
          final rewards = controller.rewards;
          final remaining = controller.remainingSelection;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  children: [
                    const _RewardBadgeHeader(),
                    const SizedBox(height: 14),
                    Text(
                      'Silahkan pilih 3 gambar\nsebagai reward',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1532),
                        height: 1.32,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      controller.selectedCount == 0
                          ? 'Kamu belum memilih gambar'
                          : 'Kamu sudah memilih ${controller.selectedCount} gambar sekarang kurang $remaining lagi',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D1F49),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _SelectedSlotsRow(controller: controller),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _contentBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                  ),
                  child: RawScrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 6.5,
                    radius: const Radius.circular(6),
                    thumbColor: _scrollbarColor,
                    trackColor: _scrollbarColor.withOpacity(0.45),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                      child: _buildGrid(rewards),
                    ),
                  ),
                ),
              ),
              _claimButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<String> rewards) {
    if (rewards.isEmpty) {
      return _emptyList();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 1,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final isSelected = controller.selectedQueue.contains(index);
        return _rewardTile(
          imageUrl: rewards[index],
          isSelected: isSelected,
          onTap: () => controller.selectReward(index),
        );
      },
    );
  }

  Widget _rewardTile({
    required String imageUrl,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _pageBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF33234A)
                : Colors.black.withOpacity(0.42),
            width: isSelected ? 2.2 : 1.1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.5),
          child: _networkImage(imageUrl, key: ValueKey(imageUrl)),
        ),
      ),
    );
  }

  Widget _networkImage(String url, {Key? key}) {
    return Image.network(
      url,
      key: key,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageFallback(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return ColoredBox(
          color: _pageBackground,
          child: const Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Color(0xFF6B4F92),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF2F2249)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Belum ada reward untuk flashcard ini.',
              style: const TextStyle(
                color: Color(0xFF2F2249),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: _pageBackground,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 30,
        color: Color(0xFF6A5A83),
      ),
    );
  }

  Widget _claimButton() {
    final canClaim =
        controller.selectedCount == FlashcardRewardController.maxSelection;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(66, 10, 66, 12),
        child: Opacity(
          opacity: canClaim ? 1 : 0.68,
          child: GestureDetector(
            onTap: canClaim ? controller.claimReward : null,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/buttom-ambil-reward.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedSlotsRow extends StatelessWidget {
  const _SelectedSlotsRow({required this.controller});

  final FlashcardRewardController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedRewardsOrdered;
    final maxSlot = FlashcardRewardController.maxSelection;

    return Row(
      children: List.generate(maxSlot, (slotIndex) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: slotIndex == maxSlot - 1 ? 0 : 12),
            child: _SlotPreview(
              imageUrl:
                  slotIndex < selected.length ? selected[slotIndex] : null,
              slotIndex: slotIndex,
              onRemove: () => controller.removeSelectionAt(slotIndex),
            ),
          ),
        );
      }),
    );
  }
}

class _SlotPreview extends StatelessWidget {
  const _SlotPreview({
    required this.imageUrl,
    required this.slotIndex,
    required this.onRemove,
  });

  final String? imageUrl;
  final int slotIndex;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return GestureDetector(
      onTap: hasImage ? onRemove : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0CEFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.5),
              width: 1.1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.5),
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFE0CEFF),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.1,
                            color: Color(0xFF6B4F92),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _slotFallback(),
                  )
                : _slotPlaceholder(slotIndex),
          ),
        ),
      ),
    );
  }

  Widget _slotPlaceholder(int slotIndex) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            color: Color(0xFF6A5A83),
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            'Slot\ngambar\nke ${slotIndex + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF33254B),
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotFallback() {
    return Container(
      color: const Color(0xFFE0CEFF),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 22,
        color: Color(0xFF6A5A83),
      ),
    );
  }
}

class _RewardBadgeHeader extends StatelessWidget {
  const _RewardBadgeHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Image.asset(
        'assets/images/header-claim-reward.png',
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
