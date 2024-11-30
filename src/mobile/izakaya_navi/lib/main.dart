import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IzakayaNaviApp());
}

class IzakayaNaviApp extends StatelessWidget {
  const IzakayaNaviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Izakaya Navi',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
