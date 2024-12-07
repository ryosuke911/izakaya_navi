import 'package:flutter/material.dart';
import '../models/hotpepper/izakaya_category.dart';

class IzakayaCategoryButtons extends StatelessWidget {
  final List<IzakayaCategory> selectedCategories;
  final Function(List<IzakayaCategory>) onCategoriesChanged;

  const IzakayaCategoryButtons({
    Key? key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: IzakayaCategory.values.map((category) {
        final isSelected = selectedCategories.contains(category);
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
            final newCategories = List<IzakayaCategory>.from(selectedCategories);
            if (selected) {
              newCategories.add(category);
            } else {
              newCategories.remove(category);
            }
            onCategoriesChanged(newCategories);
          },
        );
      }).toList(),
    );
  }
}