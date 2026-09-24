import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/deadline_provider.dart';
import 'providers/group_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuth(),
        ),
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DeadlineProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
      ],
      child: const IF03AcademicApp(),
    ),
  );
}

class IF03AcademicApp extends StatefulWidget {
  const IF03AcademicApp({super.key});

  @override
  State<IF03AcademicApp> createState() => _IF03AcademicAppState();
}

class _IF03AcademicAppState extends State<IF03AcademicApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IF03 Academic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Status 1: Initial checking (Memeriksa token di Secure Storage)
          if (auth.status == AuthStatus.initial) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Status 2: Terautentikasi (Token valid) -> Masuk ke Menu Utama
          if (auth.isAuthenticated) {
            return MainNavigationScreen(
              onToggleTheme: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            );
          }

          // Status 3: Belum login / Sesi habis -> Tampilkan Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}
