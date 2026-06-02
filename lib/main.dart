import 'package:flutter/material.dart';
// Pastikan path import ini sesuai dengan lokasi file splash_screen.dart kamu
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RE-FOOD',
      debugShowCheckedModeBanner:
          false, // Menghilangkan banner tulisan "DEBUG" di pojok kanan atas
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Di sini kita mengatur agar SplashScreen yang pertama kali muncul
      home: SplashScreen(),
    );
  }
}
