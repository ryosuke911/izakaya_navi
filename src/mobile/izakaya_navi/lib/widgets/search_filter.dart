import 'package:flutter/material.dart';

class SearchFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const SearchFilter({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  // フィルター状態
  int _selectedPersons = 2;
  String _smokingStatus = '指定なし';
  bool _hasNomihodai = false;
  bool _hasPrivateRoom = false;
  String _businessHours = '指定なし';
  double _budget = 2000;

  // 営業時間オプション
  final List<String> _businessHoursOptions = [
    '指定なし',
    '今営業中',
    '夜営業あり',
    '深夜営業あり',
  ];

  void _updateFilters() {
    widget.onFilterChanged({
      'persons': _selectedPersons,
      'smoking': _smokingStatus,
      'nomihodai': _hasNomihodai,
      'privateRoom': _hasPrivateRoom,
      'businessHours': _businessHours,
      'budget': _budget,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      _updateFilters();
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // 喫煙可否
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '喫煙',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Radio<String>(
                    value: '指定なし',
                    groupValue: _smokingStatus,
                    onChanged: (String? value) {
                      setState(() {
                        _smokingStatus = value!;
                        _updateFilters();
                      });
                    },
                  ),
                  const Text('指定なし'),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: '喫煙可',
                    groupValue: _smokingStatus,
                    onChanged: (String? value) {
                      setState(() {
                        _smokingStatus = value!;
                        _updateFilters();
                      });
                    },
                  ),
                  const Text('喫煙可'),
                  const SizedBox(width: 16),
                  Radio<String>(
                    value: '禁煙',
                    groupValue: _smokingStatus,
                    onChanged: (String? value) {
                      setState(() {
                        _smokingStatus = value!;
                        _updateFilters();
                      });
                    },
                  ),
                  const Text('禁煙'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // オプション（飲み放題、個室）
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
                title: const Text('飲み放題あり'),
                value: _hasNomihodai,
                onChanged: (bool? value) {
                  setState(() {
                    _hasNomihodai = value ?? false;
                    _updateFilters();
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('個室あり'),
                value: _hasPrivateRoom,
                onChanged: (bool? value) {
                  setState(() {
                    _hasPrivateRoom = value ?? false;
                    _updateFilters();
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 営業時間
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '営業時間',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: _businessHours,
                isExpanded: true,
                items: _businessHoursOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _businessHours = value;
                      _updateFilters();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 予算
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '予算',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _budget,
                min: 2000,
                max: 10000,
                divisions: 4,
                label: _budget >= 10000 ? '10,000円以上' : '${_budget.toInt()}円',
                onChanged: (double value) {
                  setState(() {
                    _budget = value;
                    _updateFilters();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('2,000円'),
                  Text('4,000円'),
                  Text('6,000円'),
                  Text('8,000円'),
                  Text('10,000円〜'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 