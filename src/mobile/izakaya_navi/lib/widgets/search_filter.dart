import 'package:flutter/material.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/izakaya_category.dart';
import '../services/store_service.dart';

class SearchFilter extends StatefulWidget {
  final List<IzakayaCategory> selectedCategories;
  final Function(List<IzakayaCategory>) onCategoriesChanged;
  final MiddleArea? selectedArea;
  final Function(MiddleArea?) onAreaChanged;
  final RangeValues budgetRange;
  final Function(RangeValues) onBudgetChanged;
  final int? partySize;
  final Function(int?) onPartySizeChanged;
  final bool hasPrivateRoom;
  final Function(bool) onPrivateRoomChanged;
  final bool allowsSmoking;
  final Function(bool) onSmokingChanged;
  final bool hasFreedrink;
  final Function(bool) onFreedrinkChanged;
  final bool lateNight;
  final Function(bool) onLateNightChanged;
  final StoreService storeService;

  const SearchFilter({
    Key? key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
    required this.selectedArea,
    required this.onAreaChanged,
    required this.budgetRange,
    required this.onBudgetChanged,
    required this.partySize,
    required this.onPartySizeChanged,
    required this.hasPrivateRoom,
    required this.onPrivateRoomChanged,
    required this.allowsSmoking,
    required this.onSmokingChanged,
    required this.hasFreedrink,
    required this.onFreedrinkChanged,
    required this.lateNight,
    required this.onLateNightChanged,
    required this.storeService,
  }) : super(key: key);

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  final _areaSearchController = TextEditingController();
  List<MiddleArea> _suggestedAreas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _areaSearchController.addListener(_onAreaSearchChanged);
  }

  @override
  void dispose() {
    _areaSearchController.dispose();
    super.dispose();
  }

  void _onAreaSearchChanged() async {
    final keyword = _areaSearchController.text;
    
    if (keyword.isEmpty) {
      setState(() {
        _suggestedAreas = [];
      });
      return;
    }

    if (widget.selectedArea != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final areas = await widget.storeService.suggestAreas(keyword);
      if (mounted) {
        setState(() {
          _suggestedAreas = areas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestedAreas = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エリアの検索中にエラーが発生しました: $e')),
        );
      }
    }
  }

  void _onAreaSelected(MiddleArea area) {
    setState(() {
      _areaSearchController.clear();
      _suggestedAreas = [];
      FocusScope.of(context).unfocus();
    });
    widget.onAreaChanged(area);
  }

  Widget _buildAreaInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'エリア',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.selectedArea != null)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(widget.selectedArea!.name),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  widget.onAreaChanged(null);
                },
              ),
              dense: true,
            ),
          ),
        if (widget.selectedArea == null)
          Column(
            children: [
              TextFormField(
                controller: _areaSearchController,
                decoration: InputDecoration(
                  hintText: '例: 渋谷',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              if (_suggestedAreas.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(top: 4),
                  elevation: 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _suggestedAreas.map((area) => ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(area.name),
                      dense: true,
                      onTap: () => _onAreaSelected(area),
                    )).toList(),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySelection(context),
            const SizedBox(height: 24),
            _buildAreaInput(),
            const SizedBox(height: 24),
            _buildBudgetRangeSlider(),
            const SizedBox(height: 24),
            _buildPartySizeSelector(),
            const SizedBox(height: 24),
            _buildPreferenceOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'カテゴリ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: IzakayaCategory.values.map((category) {
            final isSelected = widget.selectedCategories.contains(category);
            return FilterChip(
              avatar: Icon(
                category.icon,
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
              ),
              label: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onSelected: (selected) {
                final newCategories = List<IzakayaCategory>.from(widget.selectedCategories);
                if (selected) {
                  newCategories.add(category);
                } else {
                  newCategories.remove(category);
                }
                widget.onCategoriesChanged(newCategories);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '予算範囲',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.budgetRange.start.toInt()}円'),
                Text('${widget.budgetRange.end.toInt()}円'),
              ],
            ),
            RangeSlider(
              values: widget.budgetRange,
              min: 0,
              max: 10000,
              divisions: 20,
              labels: RangeLabels(
                '${widget.budgetRange.start.toInt()}円',
                '${widget.budgetRange.end.toInt()}円',
              ),
              onChanged: widget.onBudgetChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPartySizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '人数',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: widget.partySize,
          decoration: const InputDecoration(
            hintText: '選択してください',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: List.generate(8, (i) => i + 1).map((i) {
            return DropdownMenuItem(
              value: i,
              child: Text('$i人'),
            );
          }).toList(),
          onChanged: widget.onPartySizeChanged,
        ),
      ],
    );
  }

  Widget _buildPreferenceOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'こだわり条件',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            FilterChip(
              label: const Text('個室あり'),
              selected: widget.hasPrivateRoom,
              onSelected: widget.onPrivateRoomChanged,
            ),
            FilterChip(
              label: const Text('喫煙可'),
              selected: widget.allowsSmoking,
              onSelected: widget.onSmokingChanged,
            ),
            FilterChip(
              label: const Text('飲み放題あり'),
              selected: widget.hasFreedrink,
              onSelected: widget.onFreedrinkChanged,
            ),
            FilterChip(
              label: const Text('深夜営業'),
              selected: widget.lateNight,
              onSelected: widget.onLateNightChanged,
            ),
          ],
        ),
      ],
    );
  }
} 