import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style (status bar transparan, ikon terang)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Sipras',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const SplashScreen(), // mulai dari splash
      ),
    );
  }
}

/// Wrapper setelah SplashScreen
/// Mengecek status login lalu arahkan ke halaman yang sesuai
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<void>(
      future: authService.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika sudah login, langsung ke MainScreen
        if (authService.isLoggedIn) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
