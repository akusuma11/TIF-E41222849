import 'package:epic_story_app/feature/utils/welcome/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const Color _backgroundColor = Color(0xFFE0CEFF);
  static const Color _buttonColor = Color(0xFF7A1FA0);
  static const Color _blurLayerColor = Color(0xFF272052);

  @override
  Widget build(BuildContext context) {
    final WelcomeController controller = Get.find();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;

            return Stack(
              children: [
                Positioned(
                  left: -width * 0.35,
                  top: height * 0.1,
                  child: _buildBlurCircle(
                    size: width * 0.95,
                    opacity: 0.22,
                  ),
                ),
                Positioned(
                  right: -width * 0.42,
                  top: height * 0.2,
                  child: _buildBlurCircle(
                    size: width * 1.1,
                    opacity: 0.18,
                  ),
                ),
                Positioned(
                  top: height * 0.02,
                  left: width * 0.06,
                  child: Image.asset(
                    'assets/images/book-stack.png',
                    width: width * 0.26,
                  ),
                ),
                Positioned(
                  top: height * 0.02,
                  right: width * 0.06,
                  child: Image.asset(
                    'assets/images/coin-right.png',
                    width: width * 0.2,
                  ),
                ),
                Positioned(
                  top: height * 0.46,
                  right: width * 0.08,
                  child: Image.asset(
                    'assets/images/coin-left.png',
                    width: width * 0.09,
                  ),
                ),
                Positioned(
                  top: height * 0.61,
                  left: width * 0.08,
                  child: Image.asset(
                    'assets/images/coin-left.png',
                    width: width * 0.11,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.24),
                  child: Image.asset(
                    'assets/images/book-and-world.png',
                    width: width * 0.82,
                  ),
                ),
                Positioned(
                  right: width * 0.14,
                  bottom: height * 0.18,
                  child: Image.asset(
                    'assets/images/book-stack.png',
                    width: width * 0.12,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      width * 0.1,
                      0,
                      width * 0.1,
                      height * 0.08,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome\nto Epic Story Mobile!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.07,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Play, Learn, and Explore with Exciting\nQuizzes!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 76,
                          child: ElevatedButton(
                            onPressed: controller.signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _buttonColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logo-google.png',
                                  width: 38,
                                  height: 38,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Login Google',
                                  style: TextStyle(
                                    fontSize: width * 0.072,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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

  Widget _buildBlurCircle({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _blurLayerColor.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _blurLayerColor.withOpacity(opacity + 0.22),
            blurRadius: size * 0.45,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
    );
  }
}
