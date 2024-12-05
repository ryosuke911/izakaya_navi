import 'package:flutter/material.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/genre.dart';
import '../models/venue.dart';
import '../services/store_service.dart';
import '../services/location_service.dart';
import '../widgets/search_filter.dart';
import '../widgets/category_buttons.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final StoreService _storeService = StoreService(
    locationService: LocationService(),
  );

  List<Genre> _genres = [];
  List<Area> _areas = [];
  List<Genre> _selectedGenres = [];
  bool _isLoading = false;
  String? _errorMessage;
  late SearchFilter _searchFilter;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  // マスターデータの読み込み
  Future<void> _loadMasterData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final futures = await Future.wait([
        _storeService.getGenres(),
        _storeService.getAreas(),
      ]);

      setState(() {
        _genres = futures[0] as List<Genre>;
        _areas = futures[1] as List<Area>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'データの読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  // 検索の実行
  Future<void> _handleSearch(SearchParams params) async {
    // 選択されたジャンルを検索パラメータに追加
    final updatedParams = SearchParams.fromForm(
      keyword: params.keyword,
      area: params.area,
      genres: [..._selectedGenres, ...params.genres].toSet().toList(),  // 両方のジャンルを結合
      budgetMin: params.budget?.min,
      budgetMax: params.budget?.max,
      partySize: params.partySize,
      hasPrivateRoom: params.hasPrivateRoom,
      smokingType: params.smokingType,
      hasFreedrink: params.hasFreedrink,
      openNow: params.openNow,
      lateNight: params.lateNight,
    );

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final venues = await _storeService.searchByFilters(updatedParams);
      if (!mounted) return;

      // 検索結果画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            venues: venues,
            searchParams: updatedParams,  // 検索パラメータを渡す
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = '検索中にエラーが発生しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMasterData,
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('詳細検索'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // カテゴリ選択
              CategoryButtons(
                genres: _genres,
                onSelectionChanged: (selected) {
                  setState(() {
                    _selectedGenres = selected;
                  });
                },
              ),
              const SizedBox(height: 24),
              // 検索フィルター
              SearchFilter(
                genres: _genres,
                areas: _areas,
                onSearch: _handleSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}