import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/forecast_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ProviderScope(child: ABSSApp()));
}

class ABSSApp extends ConsumerWidget {
  const ABSSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // Update system UI overlay to match current theme
    final isDark = themeMode == ThemeMode.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'ABSS — Alerts by Stay Safe',
      debugShowCheckedModeBanner: false,
      // Default is LIGHT — outdoor readability first
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends ConsumerWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingProvider);
    if (!onboardingDone) return const OnboardingScreen();
    return const MainShell();
  }
}

//  Main Shell 
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textMuted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final lastCheckIn = ref.watch(dailyCheckInProvider);
    final regType = ref.watch(userRegistrationTypeProvider);
    final needsCheckIn = regType == UserRegistrationType.offline &&
        (lastCheckIn == null || DateTime.now().difference(lastCheckIn).inHours >= 24);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          if (needsCheckIn)
            _CheckInBanner(onCheckIn: () async {
              await ref.read(dailyCheckInProvider.notifier).checkIn();
              ref.invalidate(forecastProvider);
              ref.invalidate(alertsProvider);
            }),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: const [
                HomeScreen(),
                AlertsScreen(),
                ForecastScreen(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 16, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(index: 0, current: currentIndex, icon: Icons.home_outlined,        activeIcon: Icons.home_rounded,          label: 'Home'),
                _NavItem(index: 1, current: currentIndex, icon: Icons.warning_amber_outlined,activeIcon: Icons.warning_amber_rounded,  label: 'Alerts'),
                _NavItem(index: 2, current: currentIndex, icon: Icons.cloud_outlined,        activeIcon: Icons.cloud_rounded,          label: 'Forecast'),
                _NavItem(index: 3, current: currentIndex, icon: Icons.settings_outlined,     activeIcon: Icons.settings_rounded,       label: 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final int index;
  final int current;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.index, required this.current, required this.icon, required this.activeIcon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(active ? activeIcon : icon, key: ValueKey(active), size: 22, color: active ? activeColor : mutedColor),
            ),
            const SizedBox(height: 3),
            Text(label, style: AppText.caption(null).copyWith(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? activeColor : mutedColor)),
            const SizedBox(height: 2),
            AnimatedContainer(duration: const Duration(milliseconds: 200), width: active ? 16 : 0, height: 2,
              decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(1))),
          ],
        ),
      ),
    );
  }
}

class _CheckInBanner extends StatelessWidget {
  final VoidCallback onCheckIn;
  const _CheckInBanner({required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2340) : const Color(0xFFFFFBEB),
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : const Color(0xFFFDE68A))),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(Icons.schedule_outlined, size: 16, color: AppColors.moderate),
            const SizedBox(width: 10),
            Expanded(child: Text('Connect daily to keep your alerts fresh.', style: AppText.caption(null).copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCheckIn,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Text('Refresh', style: AppText.caption(null).copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


