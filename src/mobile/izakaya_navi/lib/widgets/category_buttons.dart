import 'package:flutter/material.dart';
import '../models/hotpepper/genre.dart';

class CategoryButtons extends StatefulWidget {
  final List<Genre> genres;
  final Function(List<Genre>) onSelectionChanged;

  const CategoryButtons({
    Key? key,
    required this.genres,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<CategoryButtons> createState() => _CategoryButtonsState();
}

class _CategoryButtonsState extends State<CategoryButtons> {
  final Set<Genre> _selectedGenres = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.genres.map((genre) {
        final isSelected = _selectedGenres.contains(genre);
        return FilterChip(
          label: Text(genre.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedGenres.add(genre);
              } else {
                _selectedGenres.remove(genre);
              }
              widget.onSelectionChanged(_selectedGenres.toList());
            });
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
        );
      }).toList(),
    );
  }
}