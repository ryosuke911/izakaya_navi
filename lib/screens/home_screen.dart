import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/store_card.dart';
import '../widgets/search_button.dart';
import '../services/store_service.dart';
import '../services/location_service.dart';
import 'search_screen.dart';
import 'search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StoreService _storeService;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _storeService = StoreService(locationService: LocationService());
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('検索キーワードを入力してください'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final venues = await _storeService.searchByKeyword(query.trim());

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            venues: venues,
            searchQuery: query,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('検索中にエラーが発生しました: $e'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: '閉じる',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }
// ... 残りのコードは変更なし ... 
} 