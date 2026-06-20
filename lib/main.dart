import 'package:dev_hup_task_week_1/features/intro/splash/splash_screen.dart';
import 'package:dev_hup_task_week_1/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/Home/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InternTaskApp());
}

class InternTaskApp extends StatelessWidget {
  const InternTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intern Task App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) =>  SplashScreen(),
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.home: (context) =>  HomeScreen(),
      },
    );
  }
}
