import 'package:epic_story_app/feature/rewards/reward_home/components/book_reward.dart';
import 'package:epic_story_app/feature/rewards/reward_home/components/flashcard_reward.dart';
import 'package:epic_story_app/feature/rewards/reward_home/components/reward_type_switcher.dart';
import 'package:epic_story_app/feature/rewards/reward_home/reward_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardHomePage extends StatelessWidget {
  const RewardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardHomeController>();

    return Scaffold(
      backgroundColor: Color(0xFFE0CEFF),
      // floatingActionButton: ElevatedButton(
      //   onPressed: () {
      //     controller.mainController.testFetchFlashcardHistories(
      //       refreshLocal: false,
      //     );
      //   },
      //   child: Text("Rev"),
      // ),
      body: Obx(() {
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 170,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF7E32AB),
                      Color(0xFFE0CEFF),
                    ],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: RewardTypeSwitcher(controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 156),
              child: RefreshIndicator(
                onRefresh: controller.refreshActiveTab,
                child: controller.isBook.value
                    ? BookReward(
                        controller: controller,
                      )
                    : FlashcardReward(
                        controller: controller,
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
