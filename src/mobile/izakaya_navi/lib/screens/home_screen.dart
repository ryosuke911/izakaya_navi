import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/store_card.dart';
import '../widgets/search_button.dart';
import '../api/places_api.dart';
import 'search_screen.dart';
import 'search_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _placesApi = PlacesApi();
  bool _isSearching = false;

  Future<void> _handleSearch(String query) async {
    print('HomeScreen._handleSearch called with query: $query'); // デバッグ用：メソッド呼び出しの出力

    if (query.isEmpty) {
      print('Empty query, showing error message'); // デバッグ用：空クエリの処理
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
      print('Calling PlacesApi.searchByText'); // デバッグ用：API呼び出しの出力
      final venues = await _placesApi.searchByText(query);
      print('Search completed, venues count: ${venues.length}'); // デバッグ用：検索結果数の出力

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(
              venues: venues,
              searchQuery: query,
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error in _handleSearch: $e'); // デバッグ用：エラーの出力
      print('Stack trace: $stackTrace'); // デバッグ用：スタックトレースの出力

      if (mounted) {
        String errorMessage = '検索中にエラーが発生しました。';
        
        // エラーの種類に応じてメッセージを変更
        if (e.toString().contains('INVALID_REQUEST')) {
          errorMessage = '検索リクエストが無効です。検索キーワードを確認してください。';
        } else if (e.toString().contains('ZERO_RESULTS')) {
          errorMessage = '検索結果が見つかりませんでした。検索キーワードを変更してお試しください。';
        } else if (e.toString().contains('OVER_QUERY_LIMIT')) {
          errorMessage = 'API制限に達しました。しばらく時間をおいてから再度お試しください。';
        } else if (e.toString().contains('REQUEST_DENIED')) {
          errorMessage = 'APIキーが無効です。システム管理者にお問い合わせください。';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '閉じる',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
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