import 'package:flutter/material.dart';

class CategoryButtons extends StatefulWidget {
  final Function(List<String>) onCategoriesChanged;

  const CategoryButtons({
    super.key,
    required this.onCategoriesChanged,
  });

  @override
  State<CategoryButtons> createState() => _CategoryButtonsState();
}

class _CategoryButtonsState extends State<CategoryButtons> {
  final List<String> _selectedCategories = [];

  // カテゴリーリスト
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_fire_department, 'label': '焼き鳥'},
    {'icon': Icons.set_meal, 'label': '海鮮'},
    {'icon': Icons.lunch_dining, 'label': '揚げ物'},
    {'icon': Icons.soup_kitchen, 'label': 'おでん'},
    {'icon': Icons.restaurant, 'label': '創作料理'},
    {'icon': Icons.bakery_dining, 'label': '餃子'},
    {'icon': Icons.edit, 'label': 'カテゴリ編集'},
  ];

  void _toggleCategory(String category) {
    if (category == 'カテゴリ編集') {
      // TODO: カテゴリ編集機能を実装
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('カテゴリ編集機能は準備中です'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
      widget.onCategoriesChanged(_selectedCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = _selectedCategories.contains(category['label']);
        
        return GestureDetector(
          onTap: () => _toggleCategory(category['label']),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  category['icon'],
                  color: isSelected ? Colors.white : Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['label'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}