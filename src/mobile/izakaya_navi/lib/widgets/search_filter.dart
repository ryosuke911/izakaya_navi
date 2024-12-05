import 'package:flutter/material.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/genre.dart';

class SearchFilter extends StatefulWidget {
  final Function(SearchParams) onSearch;
  final List<Genre> genres;
  final List<Area> areas;

  const SearchFilter({
    Key? key,
    required this.onSearch,
    required this.genres,
    required this.areas,
  }) : super(key: key);

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  final _formKey = GlobalKey<FormState>();
  
  // フォームの値
  String? _keyword;
  Area? _selectedArea;
  final List<Genre> _selectedGenres = [];
  RangeValues _budgetRange = const RangeValues(2000, 10000);
  int _partySize = 2;
  bool _hasPrivateRoom = false;
  bool _hasFreedrink = false;
  SmokingType? _smokingType;
  bool _openNow = false;
  bool _lateNight = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKeywordInput(),
          const SizedBox(height: 16),
          _buildAreaInput(),
          const SizedBox(height: 16),
          _buildPartySizeSelector(),
          const SizedBox(height: 16),
          _buildSmokingOptions(),
          const SizedBox(height: 16),
          _buildAdditionalOptions(),
          const SizedBox(height: 16),
          _buildOpeningHoursFilter(),
          const SizedBox(height: 16),
          _buildBudgetRangeSlider(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('検索'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'キーワード',
        hintText: '店名、料理名など',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _keyword = value.isEmpty ? null : value;
        });
      },
    );
  }

  Widget _buildAreaInput() {
    return DropdownButtonFormField<Area>(
      decoration: const InputDecoration(
        labelText: 'エリアを選択',
        border: OutlineInputBorder(),
      ),
      value: _selectedArea,
      items: widget.areas.map((area) {
        return DropdownMenuItem(
          value: area,
          child: Text(area.name),
        );
      }).toList(),
      onChanged: (Area? value) {
        setState(() {
          _selectedArea = value;
        });
      },
    );
  }

  Widget _buildPartySizeSelector() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: '人数',
        border: OutlineInputBorder(),
      ),
      value: _partySize,
      items: List.generate(8, (index) {
        final number = index + 1;
        return DropdownMenuItem(
          value: number,
          child: Text('$number人'),
        );
      }),
      onChanged: (value) {
        setState(() {
          _partySize = value ?? 2;
        });
      },
    );
  }

  Widget _buildSmokingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('喫煙'),
        Row(
          children: [
            Radio<SmokingType?>(
              value: null,
              groupValue: _smokingType,
              onChanged: (value) {
                setState(() {
                  _smokingType = value;
                });
              },
            ),
            const Text('指定なし'),
            Radio<SmokingType>(
              value: SmokingType.smoking,
              groupValue: _smokingType,
              onChanged: (value) {
                setState(() {
                  _smokingType = value;
                });
              },
            ),
            const Text('喫煙可'),
            Radio<SmokingType>(
              value: SmokingType.noSmoking,
              groupValue: _smokingType,
              onChanged: (value) {
                setState(() {
                  _smokingType = value;
                });
              },
            ),
            const Text('禁煙'),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('オプション'),
        Row(
          children: [
            Checkbox(
              value: _hasFreedrink,
              onChanged: (value) {
                setState(() {
                  _hasFreedrink = value ?? false;
                });
              },
            ),
            const Text('飲み放題'),
            const SizedBox(width: 16),
            Checkbox(
              value: _hasPrivateRoom,
              onChanged: (value) {
                setState(() {
                  _hasPrivateRoom = value ?? false;
                });
              },
            ),
            const Text('個室'),
          ],
        ),
      ],
    );
  }

  Widget _buildOpeningHoursFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('営業時間'),
        Row(
          children: [
            Checkbox(
              value: _openNow,
              onChanged: (value) {
                setState(() {
                  _openNow = value ?? false;
                });
              },
            ),
            const Text('現在営業中'),
            const SizedBox(width: 16),
            Checkbox(
              value: _lateNight,
              onChanged: (value) {
                setState(() {
                  _lateNight = value ?? false;
                });
              },
            ),
            const Text('深夜営業'),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('予算範囲'),
        RangeSlider(
          values: _budgetRange,
          min: 2000,
          max: 10000,
          divisions: 16,
          labels: RangeLabels(
            '${_budgetRange.start.toInt()}円',
            '${_budgetRange.end.toInt()}円',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _budgetRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_budgetRange.start.toInt()}円'),
            Text('${_budgetRange.end.toInt()}円'),
          ],
        ),
      ],
    );
  }

  void _handleSearch() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('エリアを選択してください'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final params = SearchParams.fromForm(
        keyword: _keyword,
        area: _selectedArea,
        genres: _selectedGenres,
        budgetMin: _budgetRange.start.toInt(),
        budgetMax: _budgetRange.end.toInt(),
        partySize: _partySize,
        hasPrivateRoom: _hasPrivateRoom,
        smokingType: _smokingType,
        hasFreedrink: _hasFreedrink,
        openNow: _openNow,
        lateNight: _lateNight,
      );
      widget.onSearch(params);
    }
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  SearchParams getSearchParams() {
    return SearchParams.fromForm(
      keyword: _keyword,
      area: _selectedArea,
      genres: _selectedGenres,
      budgetMin: _budgetRange.start.toInt(),
      budgetMax: _budgetRange.end.toInt(),
      partySize: _partySize,
      hasPrivateRoom: _hasPrivateRoom,
      smokingType: _smokingType,
      hasFreedrink: _hasFreedrink,
      openNow: _openNow,
      lateNight: _lateNight,
    );
  }

  void setSearchParams(SearchParams params) {
    setState(() {
      _keyword = params.keyword;
      _selectedArea = params.area;
      _selectedGenres.clear();
      _selectedGenres.addAll(params.genres);
      if (params.budget != null) {
        _budgetRange = RangeValues(
          params.budget!.min?.toDouble() ?? 2000,
          params.budget!.max?.toDouble() ?? 10000,
        );
      }
      _partySize = params.partySize ?? 2;
      _hasPrivateRoom = params.hasPrivateRoom ?? false;
      _smokingType = params.smokingType;
      _hasFreedrink = params.hasFreedrink ?? false;
      _openNow = params.openNow ?? false;
      _lateNight = params.lateNight ?? false;
    });
  }
} 