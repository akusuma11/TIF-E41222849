import 'package:epic_story_app/feature/favorites/presentation/favorite_home/favorite_home_page.dart';
import 'package:epic_story_app/feature/home/home_page.dart';
import 'package:epic_story_app/feature/profiles/presentation/profile_page.dart';
import 'package:epic_story_app/feature/rewards/reward_home/reward_home_page.dart';
import 'package:epic_story_app/feature/utils/navigation/epic_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EpicNavigationPage extends StatelessWidget {
  const EpicNavigationPage({super.key});

  static const Color _navGradientTop = Color(0xFF7E32AB);
  static const Color _navGradientBottom = Color(0xFF331445);

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      title: 'Home',
      inactiveIcon: 'assets/images/ic-nav-home-inactive.png',
      activeIcon: 'assets/images/ic-nav-home-active.png',
    ),
    _NavItemData(
      title: 'Koleksi',
      inactiveIcon: 'assets/images/ic-nav-koleksi-inactive.png',
      activeIcon: 'assets/images/ic-nav-koleksi-active.png',
    ),
    _NavItemData(
      title: 'Hadiah',
      inactiveIcon: 'assets/images/ic-nav-hadian-inactive.png',
      activeIcon: 'assets/images/ic-nav-hadiah-active.png',
    ),
    _NavItemData(
      title: 'Profil',
      inactiveIcon: 'assets/images/ic-nav-profile-inactive.png',
      activeIcon: 'assets/images/ic-nav-profile-active.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final EpicNavigationController controller = Get.find();

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.selectedIndex.value,
            children: const [
              HomePage(),
              FavoriteHomePage(),
              RewardHomePage(),
              ProfilePage(),
            ],
          )),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_navGradientTop, _navGradientBottom],
            stops: [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_navItems.length, (index) {
                final _NavItemData item = _navItems[index];
                final bool isActive = controller.selectedIndex.value == index;
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                  child: _buildNavItem(
                    isActive: isActive,
                    activeIconPath: item.activeIcon,
                    inactiveIconPath: item.inactiveIcon,
                    title: item.title,
                    onTap: () => controller.changePage(index),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required bool isActive,
    required String activeIconPath,
    required String inactiveIconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    final String iconPath = isActive ? activeIconPath : inactiveIconPath;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: isActive ? 108 : 64,
          height: 64,
          alignment: Alignment.center,
          child: Semantics(
            label: title,
            button: true,
            selected: isActive,
            child: Image.asset(
              iconPath,
              key: ValueKey<String>('${title.toLowerCase()}_$isActive'),
              width: isActive ? 108 : 64,
              height: isActive ? 64 : 64,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.title,
    required this.inactiveIcon,
    required this.activeIcon,
  });

  final String title;
  final String inactiveIcon;
  final String activeIcon;
}
