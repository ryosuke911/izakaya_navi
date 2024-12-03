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
  final TextEditingController _areaController = TextEditingController();
  int _selectedPersons = 2;
  String _smokingStatus = '指定なし';
  bool _hasNomihodai = false;
  bool _hasPrivateRoom = false;
  String _businessHours = '指定なし';
  RangeValues _budgetRange = const RangeValues(2000, 5000);

  void _updateFilters() {
    widget.onFilterChanged({
      'area': _areaController.text,
      'persons': _selectedPersons,
      'smoking': _smokingStatus,
      'nomihodai': _hasNomihodai,
      'privateRoom': _hasPrivateRoom,
      'businessHours': _businessHours,
      'budgetMin': _budgetRange.start,
      'budgetMax': _budgetRange.end,
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // エリア・駅名入力
        _buildSection(
          title: 'エリア・駅名',
          child: TextField(
            controller: _areaController,
            decoration: InputDecoration(
              hintText: 'エリア・駅名を入力',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _updateFilters();
            },
          ),
        ),

        // 人数選択
        _buildSection(
          title: '人数',
          child: DropdownButton<int>(
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
        ),

        // 喫煙可否
        _buildSection(
          title: '喫煙',
          child: Wrap(
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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

        // オプション
        _buildSection(
          title: 'オプション',
          child: Column(
            children: [
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

        // 営業時間
        _buildSection(
          title: '営業時間',
          child: Wrap(
            spacing: 16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: '指定なし',
                    groupValue: _businessHours,
                    onChanged: (String? value) {
                      setState(() {
                        _businessHours = value!;
                        _updateFilters();
                      });
                    },
                  ),
                  const Text('指定なし'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: '今営業中',
                    groupValue: _businessHours,
                    onChanged: (String? value) {
                      setState(() {
                        _businessHours = value!;
                        _updateFilters();
                      });
                    },
                  ),
                  const Text('今営業中'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: '深夜営業あり',
                    groupValue: _businessHours,
                    onChanged: (String? value) {
                      setState(() {
                        _businessHours = value!;
                        _updateFilters();
                      });
                    },
                  ),
                  const Text('深夜営業あり'),
                ],
              ),
            ],
          ),
        ),

        // 予算
        _buildSection(
          title: '予算',
          child: Column(
            children: [
              RangeSlider(
                values: _budgetRange,
                min: 2000,
                max: 10000,
                divisions: 8,
                labels: RangeLabels(
                  _budgetRange.start >= 10000 ? '10,000円以上' : '${_budgetRange.start.toInt()}円',
                  _budgetRange.end >= 10000 ? '10,000円以上' : '${_budgetRange.end.toInt()}円',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _budgetRange = values;
                    _updateFilters();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('2,000円'),
                  Text('10,000円以上'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }
} 