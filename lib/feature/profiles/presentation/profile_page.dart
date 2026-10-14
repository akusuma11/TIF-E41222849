import 'package:epic_story_app/core/constants/size/epic_size.dart';
import 'package:epic_story_app/core/styles/epic_app_size.dart';
import 'package:epic_story_app/domain/entities/children_entity.dart';
import 'package:epic_story_app/feature/profiles/presentation/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _pageBackground = Color(0xFFC6B2E6);
  static const Color _profileBox = Color(0xFFB400FF);
  static const Color _logoutButton = Color(0xFFFF0000);

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Obx(
          () {
            final ChildrenEntity? children = controller.childrenData.value;
            if (children == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7E32AB),
                ),
              );
            }

            final photoUrl = children.photoPicture;
            final initials = _initials(children.fullName ?? '');

            return Column(
              children: [
                SizedBox(
                  height: 146,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: EpicAppSize.calculatedSize(95),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 8, 125, 8),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(18),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2C0B3A),
                              Color(0xFF7E32AB),
                            ],
                            stops: [0.1, 1.0],
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: EpicAppSize.calculatedSize(50)),
                            Image.asset(
                              'assets/images/coin-gancet.png',
                              width: EpicAppSize.calculatedSize(60),
                              height: EpicAppSize.calculatedSize(60),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: EpicAppSize.calculatedSize(8)),
                            Text(
                              'Profil Kamu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: EpicAppSize.calculatedSize(30),
                                fontWeight: FontWeight.w900,
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: Color(0x3D000000),
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -12,
                        right: 6,
                        child: Image.asset(
                          'assets/images/icon-top-bar.png',
                          width: EpicAppSize.calculatedSize(100),
                          height: EpicAppSize.calculatedSize(100),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 240,
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                          decoration: BoxDecoration(
                            color: _profileBox,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x29000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 56,
                                backgroundColor: const Color(0xFFC8A2E8),
                                backgroundImage:
                                    photoUrl != null && photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : null,
                                child: photoUrl == null || photoUrl.isEmpty
                                    ? Text(
                                        initials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                children.fullName ?? 'Nama tidak tersedia',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: EpicSize.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: EpicAppSize.calculatedSize(30),
                                  height: 0.95,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                children.email ?? '-',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: EpicAppSize.calculatedSize(18),
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 68),
                        SizedBox(
                          width: 122,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: controller.logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _logoutButton,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                // side: const BorderSide(
                                //   color: Colors.white,
                                //   width: 1.1,
                                // ),
                              ),
                            ),
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: EpicAppSize.calculatedSize(22),
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '??';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final result = (first + last).toUpperCase();
    return result.isEmpty ? '??' : result;
  }
}
