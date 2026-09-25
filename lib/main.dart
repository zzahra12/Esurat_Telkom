import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 👈 1. Tambahkan import ini
import 'views/login_page.dart'; 

void main() async { // 👈 2. Tambahkan async di sini
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null); // 👈 3. Tambahkan baris ini
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eSurat App',
      // Menghilangkan banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        fontFamily: 'Roboto', // Atau font default aplikasi
        primaryColor: const Color(0xFF140F47),
        scaffoldBackgroundColor: Colors.white,
      ),
      // Halaman pertama yang dibuka saat aplikasi dijalankan
      home: const LoginScreen(), 
    );
  }
}