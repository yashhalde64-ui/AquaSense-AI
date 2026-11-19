import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:watermangment/screens/login_screen.dart';
import 'package:watermangment/widgets/screen_background.dart';
import 'package:watermangment/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 30),
                  // Logo & Title
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'AquaSense AI',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Water • Better Cities',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  
                  // Bottom Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      children: [
                        const Text(
                          'Monitor • Report • Improve',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Together for a Better Tomorrow',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Swipe to Get Started Button
                        Builder(
                          builder: (context) {
                            return SlideAction(
                              onSubmit: () {
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  ),
                                );
                                return null;
                              },
                              borderRadius: 30,
                              elevation: 0,
                              innerColor: AppTheme.backgroundDark,
                              outerColor: Colors.white.withOpacity(0.15),
                              sliderButtonIcon: const Icon(Icons.arrow_forward, color: Colors.white),
                              text: 'Swipe to Get Started',
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              sliderRotate: false,
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
