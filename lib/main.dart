import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_text_styles.dart';
import 'core/utils/app_bloc_observer.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  runApp(const FunngroAssessmentApp());
}

class FunngroAssessmentApp extends StatelessWidget {
  final Widget? home;

  const FunngroAssessmentApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          titleTextStyle: AppTextStyles.appBarTitle,
        ),
      ),
      home: home ?? const SplashScreen(),
    );
  }
}
