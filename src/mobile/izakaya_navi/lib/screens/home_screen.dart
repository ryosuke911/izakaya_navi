import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/store_card.dart';
import '../widgets/search_button.dart';
import '../services/store_service.dart';
import '../services/location_service.dart';
import 'search_screen.dart';
import 'search_result_screen.dart';
import '../models/hotpepper/search_params.dart';

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
      print('Searching for: $query');
      final venues = await _storeService.searchByKeyword(query.trim());
      print('Found ${venues.length} venues');

      if (!mounted) return;

      if (venues.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('検索結果が見つかりませんでした'),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            venues: venues,
            searchParams: SearchParams(keyword: query),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('検索中にエラーが発生しました: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('居酒屋なび'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: プロフィール画面に遷移
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 検索エリア
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // エリア検索バー
                    CustomSearchBar(
                      onSearch: _handleSearch,
                    ),
                    const SizedBox(height: 16),
                    
                    // 検索ボタン
                    Row(
                      children: [
                        Expanded(
                          child: SearchButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SearchScreen(),
                                ),
                              );
                            },
                            icon: Icons.tune,
                            label: '詳細検索',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SearchButton(
                            onPressed: () {
                              // TODO: 現在地周辺の検索結果画面に遷移
                            },
                            icon: Icons.location_on,
                            label: '現在地から探す',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // おすすめ店舗リスト
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'おすすめの居酒屋',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: おすすめ一覧画面に遷移
                            },
                            child: const Text('もっと見る'),
                          ),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('おすすめ店舗は準備中です'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isSearching)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}