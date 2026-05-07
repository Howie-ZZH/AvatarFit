import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_flow.dart';
import '../theme/app_theme.dart';

class FitGameApp extends StatelessWidget {
  const FitGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitGame',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const OnboardingFlow(),
    );
  }
}
