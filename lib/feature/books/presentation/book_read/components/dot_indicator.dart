import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.length,
    required this.index,
    this.activeColor = const Color(0xFF1F1F1F),
    this.inactiveColor = const Color(0xFFD9D9D9),
    this.activeBorderColor,
  });

  final int length;
  final int index;
  final Color activeColor;
  final Color inactiveColor;
  final Color? activeBorderColor;

  @override
  Widget build(BuildContext context) {
    if (length == 0) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
            border: isActive && activeBorderColor != null
                ? Border.all(color: activeBorderColor!, width: 1)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
