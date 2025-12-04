import 'package:flutter/material.dart';
import 'screens/splashanimacion.dart';
import 'screens/login.dart';

void main() {
  runApp(const NequiKillApp());
}

class NequiKillApp extends StatelessWidget {
  const NequiKillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nequi Kill',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF200020),
        scaffoldBackgroundColor: const Color(0xFF200020),
        fontFamily: 'Manrope',
        canvasColor: const Color(0xFF200020),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF200020),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF200020),
      child: SplashAnimacion(
        onAnimationComplete: () {
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
    );
  }
}

