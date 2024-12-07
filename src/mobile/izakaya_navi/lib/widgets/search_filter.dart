import 'package:flutter/material.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/search_params.dart';

class SearchFilter extends StatelessWidget {
  final Area? selectedArea;
  final Function(Area?) onAreaChanged;
  final BudgetRange? budgetRange;
  final Function(BudgetRange?) onBudgetChanged;
  final int? partySize;
  final Function(int?) onPartySizeChanged;
  final bool? hasPrivateRoom;
  final Function(bool?) onPrivateRoomChanged;
  final SmokingType? smokingType;
  final Function(SmokingType?) onSmokingTypeChanged;
  final bool? hasFreedrink;
  final Function(bool?) onFreedrinkChanged;
  final bool? openNow;
  final Function(bool?) onOpenNowChanged;
  final bool? lateNight;
  final Function(bool?) onLateNightChanged;

  const SearchFilter({
    Key? key,
    required this.selectedArea,
    required this.onAreaChanged,
    required this.budgetRange,
    required this.onBudgetChanged,
    required this.partySize,
    required this.onPartySizeChanged,
    required this.hasPrivateRoom,
    required this.onPrivateRoomChanged,
    required this.smokingType,
    required this.onSmokingTypeChanged,
    required this.hasFreedrink,
    required this.onFreedrinkChanged,
    required this.openNow,
    required this.onOpenNowChanged,
    required this.lateNight,
    required this.onLateNightChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('詳細条件'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 予算範囲
              const Text('予算範囲'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '下限',
                        suffixText: '円',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: budgetRange?.min?.toString(),
                      onChanged: (value) {
                        final min = int.tryParse(value);
                        onBudgetChanged(BudgetRange(
                          min: min,
                          max: budgetRange?.max,
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '上限',
                        suffixText: '円',
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: budgetRange?.max?.toString(),
                      onChanged: (value) {
                        final max = int.tryParse(value);
                        onBudgetChanged(BudgetRange(
                          min: budgetRange?.min,
                          max: max,
                        ));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 人数
              const Text('人数'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: partySize,
                decoration: const InputDecoration(
                  hintText: '選択してください',
                ),
                items: List.generate(8, (i) => i + 1).map((i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text('$i人'),
                  );
                }).toList(),
                onChanged: onPartySizeChanged,
              ),
              const SizedBox(height: 24),

              // 喫煙
              const Text('喫煙'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('指定なし'),
                    selected: smokingType == null,
                    onSelected: (selected) {
                      if (selected) onSmokingTypeChanged(null);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('禁煙'),
                    selected: smokingType == SmokingType.noSmoking,
                    onSelected: (selected) {
                      if (selected) onSmokingTypeChanged(SmokingType.noSmoking);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('喫煙可'),
                    selected: smokingType == SmokingType.smoking,
                    onSelected: (selected) {
                      if (selected) onSmokingTypeChanged(SmokingType.smoking);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('分煙'),
                    selected: smokingType == SmokingType.separatedArea,
                    onSelected: (selected) {
                      if (selected) {
                        onSmokingTypeChanged(SmokingType.separatedArea);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // その他のオプション
              const Text('オプション'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('個室あり'),
                    selected: hasPrivateRoom ?? false,
                    onSelected: onPrivateRoomChanged,
                  ),
                  FilterChip(
                    label: const Text('飲み放題あり'),
                    selected: hasFreedrink ?? false,
                    onSelected: onFreedrinkChanged,
                  ),
                  FilterChip(
                    label: const Text('現在営業中'),
                    selected: openNow ?? false,
                    onSelected: onOpenNowChanged,
                  ),
                  FilterChip(
                    label: const Text('深夜営業あり'),
                    selected: lateNight ?? false,
                    onSelected: onLateNightChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 