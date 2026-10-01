import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'providers/profile_provider.dart';
import 'providers/task_provider.dart';
import 'providers/assistant_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/security_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/navigation/main_navigation_screen.dart';
import 'screens/lock/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final profileProvider = ProfileProvider();
  final taskProvider = TaskProvider();
  final assistantProvider = AssistantProvider();
  final searchProvider = SearchProvider();
  final themeProvider = ThemeProvider();
  final securityProvider = SecurityProvider();

  // Initialize stored states
  await profileProvider.loadProfile();
  await taskProvider.loadTasks();
  await securityProvider.initSecurity();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: assistantProvider),
        ChangeNotifierProvider.value(value: searchProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: securityProvider),
      ],
      child: const ProfileFlowApp(),
    ),
  );
}

class ProfileFlowApp extends StatefulWidget {
  const ProfileFlowApp({Key? key}) : super(key: key);

  @override
  State<ProfileFlowApp> createState() => _ProfileFlowAppState();
}

class _ProfileFlowAppState extends State<ProfileFlowApp> {
  bool _isUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final securityProvider = context.watch<SecurityProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return MaterialApp(
      title: 'ProfileFlow Assistant',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _resolveInitialScreen(
        securityProvider: securityProvider,
        profileProvider: profileProvider,
      ),
    );
  }

  Widget _resolveInitialScreen({
    required SecurityProvider securityProvider,
    required ProfileProvider profileProvider,
  }) {
    // If PIN lock is enabled and session is not yet unlocked
    if (securityProvider.isPinEnabled && !_isUnlocked) {
      return PinLockScreen(
        onUnlocked: () {
          setState(() {
            _isUnlocked = true;
          });
        },
      );
    }

    // If profile is completely empty (first time open)
    if (profileProvider.profile.isCompletelyEmpty) {
      return const OnboardingScreen();
    }

    // Default: Main app navigation
    return const MainNavigationScreen();
  }
}
