import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'services/navigation_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 画面の向きを縦方向に固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationService()),
      ],
      child: const IzakayaNaviApp(),
    ),
  );
}

class IzakayaNaviApp extends StatelessWidget {
  const IzakayaNaviApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '居酒屋ナビ',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        // その他のテーマ設定
      ),
      // ダークモードのテーマ設定
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepOrange,
        // ダークモード用のその他のテーマ設定
      ),
      
      // 初期ルート設定
      initialRoute: '/auth',
      
      // ルート定義
      routes: {
        '/': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
      },
      
      // 404エラー時の処理
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => const HomeScreen(),
        );
      },
      
      // デバッグバナーを非表示
      debugShowCheckedModeBanner: false,
    );
  }
}
