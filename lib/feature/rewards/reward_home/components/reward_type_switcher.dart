import 'package:epic_story_app/feature/rewards/reward_home/reward_home_controller.dart';
import 'package:flutter/material.dart';

class RewardTypeSwitcher extends StatelessWidget {
  const RewardTypeSwitcher({super.key, required this.controller});

  final RewardHomeController controller;

  @override
  Widget build(BuildContext context) {
    final bool isBookActive = controller.isBook.value;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFECB63F), Color(0xFF0088FF)],
        ),
        border: Border.all(color: Colors.black87, width: 1.4),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment:
                  isBookActive ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        _activeAssetPath(isBookActive),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _item(
                    label: 'Buku',
                    value: true,
                    active: isBookActive,
                  ),
                ),
                Expanded(
                  child: _item(
                    label: 'Flashcard',
                    value: false,
                    active: !isBookActive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _activeAssetPath(bool isBookActive) {
    if (isBookActive) {
      return 'assets/images/button-book-active.png';
    }

    return 'assets/images/button-flashcard-acive.png';
  }

  Widget _item({
    required String label,
    required bool value,
    required bool active,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => controller.isBook.value = value,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            style: TextStyle(
              color: active ? Colors.transparent : Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
              shadows: active
                  ? null
                  : const [
                      Shadow(
                        color: Color(0xFF171717),
                        offset: Offset(1.2, 1.2),
                        blurRadius: 0,
                      ),
                      Shadow(
                        color: Color(0xB3000000),
                        offset: Offset(0, 0),
                        blurRadius: 5,
                      ),
                    ],
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
