import 'package:flutter/material.dart';

class RewardClaimButton extends StatelessWidget {
  const RewardClaimButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 41,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFFF1F1F),
            width: 1.6,
          ),
          foregroundColor: Colors.black,
          backgroundColor: const Color(0xFFFFE588),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          'Dapatkan Reward',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
