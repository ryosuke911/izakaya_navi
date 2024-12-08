import 'package:flutter/material.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/izakaya_category.dart';
import '../models/hotpepper/area.dart';
import '../widgets/search_filter.dart';
import '../services/store_service.dart';
import '../services/location_service.dart';
import 'search_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _keywordController = TextEditingController();
  MiddleArea? _selectedArea;
  final List<IzakayaCategory> _selectedCategories = [];
  RangeValues _budgetRange = const RangeValues(2000, 6000);
  int? _partySize;
  bool _hasPrivateRoom = false;
  bool _allowsSmoking = false;
  bool _hasFreedrink = false;
  bool _lateNight = false;
  bool _isLoading = false;

  late final StoreService _storeService;

  @override
  void initState() {
    super.initState();
    _storeService = StoreService(locationService: LocationService());
    _initializeAreas();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<void> _initializeAreas() async {
    try {
      await _storeService.initialize();
    } catch (e) {
      print('エリアデータの初期化に失敗しました: $e');
    }
  }

  void _search() async {
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エリアを選択してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final params = SearchParams(
        keyword: _keywordController.text.isNotEmpty ? _keywordController.text : null,
        area: _selectedArea,
        categories: _selectedCategories,
        budget: BudgetRange(
          min: _budgetRange.start.toInt(),
          max: _budgetRange.end.toInt(),
        ),
        partySize: _partySize,
        hasPrivateRoom: _hasPrivateRoom ? true : null,
        smokingType: _allowsSmoking ? SmokingType.smoking : null,
        hasFreedrink: _hasFreedrink ? true : null,
        lateNight: _lateNight ? true : null,
      );

      final results = await _storeService.searchByFilters(params);

      if (!mounted) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('条件に一致する店舗が見つかりませんでした')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            venues: results,
            searchParams: params,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('検索中にエラーが発生しました: $e')),
      );
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
      body: Stack(
        children: [
          SearchFilter(
            selectedCategories: _selectedCategories,
            onCategoriesChanged: (categories) {
              setState(() {
                _selectedCategories.clear();
                _selectedCategories.addAll(categories);
              });
            },
            selectedArea: _selectedArea,
            onAreaChanged: (area) {
              setState(() {
                _selectedArea = area;
              });
            },
            budgetRange: _budgetRange,
            onBudgetChanged: (values) {
              setState(() {
                _budgetRange = values;
              });
            },
            partySize: _partySize,
            onPartySizeChanged: (value) {
              setState(() {
                _partySize = value;
              });
            },
            hasPrivateRoom: _hasPrivateRoom,
            onPrivateRoomChanged: (value) {
              setState(() {
                _hasPrivateRoom = value;
              });
            },
            allowsSmoking: _allowsSmoking,
            onSmokingChanged: (value) {
              setState(() {
                _allowsSmoking = value;
              });
            },
            hasFreedrink: _hasFreedrink,
            onFreedrinkChanged: (value) {
              setState(() {
                _hasFreedrink = value;
              });
            },
            lateNight: _lateNight,
            onLateNightChanged: (value) {
              setState(() {
                _lateNight = value;
              });
            },
            storeService: _storeService,
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _search,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('検索する'),
          ),
        ),
      ),
    );
  }
}