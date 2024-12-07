import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/search_result_screen.dart';
import 'models/venue.dart';
import 'models/hotpepper/search_params.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
      routes: {
        '/search': (context) => const SearchScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/search_results') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => SearchResultScreen(
              venues: args['venues'] as List<Venue>,
              searchParams: args['searchParams'] as SearchParams,
            ),
          );
        }
        return null;
      },
    );
  }
}
