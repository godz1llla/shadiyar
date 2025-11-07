import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TiriTarihApp());
}

class TiriTarihApp extends StatelessWidget {
  const TiriTarihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тірі Тарих',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF9500),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9500),
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
          onSurfaceVariant: Color(0xFFAAAAAA),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
