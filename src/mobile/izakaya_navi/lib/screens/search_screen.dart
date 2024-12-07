import 'package:flutter/material.dart';
import '../models/hotpepper/izakaya_category.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/area.dart';
import '../services/store_service.dart';
import '../services/location_service.dart';
import '../widgets/category_buttons.dart';
import '../widgets/search_filter.dart';
import '../models/venue.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _keywordController = TextEditingController();
  final List<IzakayaCategory> _selectedCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 検索フィルター用の状態
  Area? _selectedArea;
  BudgetRange? _budgetRange;
  int? _partySize;
  bool? _hasPrivateRoom;
  SmokingType? _smokingType;
  bool? _hasFreedrink;
  bool? _openNow;
  bool? _lateNight;

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final params = SearchParams(
        keyword: _keywordController.text,
        categories: _selectedCategories,
      );

      // StoreServiceのインスタンスを取得（依存性注入の実装に応じて変更）
      final storeService = StoreService(
        locationService: LocationService(),
      );

      final results = await storeService.searchByFilters(params);

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/search_results',
          arguments: {
            'venues': results,
            'searchParams': params,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('検索中にエラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('居酒屋を探す'),
      ),
      body: _errorMessage != null && _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _search,
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // キーワード検索フィールド
                  TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      labelText: 'キーワード',
                      hintText: '店名、料理名など',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // カテゴリ選択セクション
                  const Text(
                    'カテゴリ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IzakayaCategoryButtons(
                    selectedCategories: _selectedCategories,
                    onCategoriesChanged: (categories) {
                      setState(() {
                        _selectedCategories
                          ..clear()
                          ..addAll(categories);
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // 詳細検索フィルター
                  SearchFilter(
                    selectedArea: _selectedArea,
                    onAreaChanged: (area) {
                      setState(() => _selectedArea = area);
                    },
                    budgetRange: _budgetRange,
                    onBudgetChanged: (budget) {
                      setState(() => _budgetRange = budget);
                    },
                    partySize: _partySize,
                    onPartySizeChanged: (size) {
                      setState(() => _partySize = size);
                    },
                    hasPrivateRoom: _hasPrivateRoom,
                    onPrivateRoomChanged: (value) {
                      setState(() => _hasPrivateRoom = value);
                    },
                    smokingType: _smokingType,
                    onSmokingTypeChanged: (type) {
                      setState(() => _smokingType = type);
                    },
                    hasFreedrink: _hasFreedrink,
                    onFreedrinkChanged: (value) {
                      setState(() => _hasFreedrink = value);
                    },
                    openNow: _openNow,
                    onOpenNowChanged: (value) {
                      setState(() => _openNow = value);
                    },
                    lateNight: _lateNight,
                    onLateNightChanged: (value) {
                      setState(() => _lateNight = value);
                    },
                  ),
                  const SizedBox(height: 32),

                  // 検索ボタン
                  ElevatedButton(
                    onPressed: _isLoading ? null : _search,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            '検索',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}