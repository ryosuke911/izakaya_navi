import 'package:flutter/material.dart';
import '../widgets/search_filter.dart';
import '../widgets/category_buttons.dart';
import '../services/search_service.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchService = SearchService();
  final Map<String, dynamic> _searchFilters = {};
  final List<String> _selectedCategories = [];
  bool _isSearching = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleSearch() async {
    // 検索条件の検証
    if (_searchFilters['area']?.isEmpty ?? true) {
      _showError('エリア・駅名を入力してください');
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final venues = await _searchService.searchByFilters(
        area: _searchFilters['area'],
        categories: _selectedCategories,
        personCount: _searchFilters['persons'],
        smokingStatus: _searchFilters['smoking'],
        hasNomihodai: _searchFilters['nomihodai'],
        hasPrivateRoom: _searchFilters['privateRoom'],
        businessHours: _searchFilters['businessHours'],
        minBudget: _searchFilters['budgetMin']?.toDouble(),
        maxBudget: _searchFilters['budgetMax']?.toDouble(),
      );

      if (!mounted) return;

      // 検索結果画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            venues: venues,
            searchQuery: _searchFilters['area'],
          ),
        ),
      );
    } catch (e) {
      _showError('検索中にエラーが発生しました。もう一度お試しください。');
      print('Search error: $e');
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
        title: const Text('詳細検索'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // カテゴリ選択
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'カテゴリー',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CategoryButtons(
                          onCategoriesChanged: (categories) {
                            setState(() {
                              _selectedCategories.clear();
                              _selectedCategories.addAll(categories);
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 詳細条件
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '詳細条件',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SearchFilter(
                        onFilterChanged: (filters) {
                          setState(() {
                            _searchFilters.clear();
                            _searchFilters.addAll(filters);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 検索ボタン
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _handleSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isSearching ? '検索中...' : '検索する',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ローディングオーバーレイ
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