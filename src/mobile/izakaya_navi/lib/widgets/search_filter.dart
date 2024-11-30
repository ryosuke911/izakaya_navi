import 'package:flutter/material.dart';

class SearchFilter extends StatefulWidget {
  const SearchFilter({super.key});

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  RangeValues _priceRange = const RangeValues(1000, 10000);
  int _selectedPersons = 2;
  bool _hasPrivateRoom = false;
  bool _hasNomihodai = false;
  bool _hasTabehodai = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 予算範囲
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '予算範囲',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RangeSlider(
          values: _priceRange,
          min: 1000,
          max: 10000,
          divisions: 18,
          labels: RangeLabels(
            '${_priceRange.start.round()}円',
            '${_priceRange.end.round()}円',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),

        // 人数選択
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                '人数',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _selectedPersons,
                items: List.generate(8, (index) => index + 1)
                    .map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value人'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  if (value != null) {
                    setState(() {
                      _selectedPersons = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // オプション
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'オプション',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('個室あり'),
                value: _hasPrivateRoom,
                onChanged: (bool? value) {
                  setState(() {
                    _hasPrivateRoom = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('飲み放題あり'),
                value: _hasNomihodai,
                onChanged: (bool? value) {
                  setState(() {
                    _hasNomihodai = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('食べ放題あり'),
                value: _hasTabehodai,
                onChanged: (bool? value) {
                  setState(() {
                    _hasTabehodai = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 