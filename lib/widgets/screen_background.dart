import 'package:flutter/material.dart';

class ScreenBackground extends StatelessWidget {
  final Widget child;
  const ScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF031627), // Dark blue top
            Color(0xFF0A345C), // Lighter blue middle
            Color(0xFF031627), // Dark blue bottom
          ],
        ),
      ),
      child: child,
    );
  }
}
