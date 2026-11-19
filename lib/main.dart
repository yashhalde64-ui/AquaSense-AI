import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/screens/splash_screen.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/services/mongo_service.dart';
import 'package:watermangment/services/gemini_service.dart';
import 'package:watermangment/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services
  await MongoDatabase.connect();
  GeminiService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const CivicPulseApp(),
    ),
  );
}

class CivicPulseApp extends StatelessWidget {
  const CivicPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
