import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- IMPORT INI UNTUK FORMAT TANGGAL
import 'screens/splash_screen.dart';

void main() async {
  // Wajib ditambahkan jika kita menggunakan fungsi async di dalam main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data lokal untuk format tanggal Bahasa Indonesia ('id_ID')
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RE-FOOD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}
