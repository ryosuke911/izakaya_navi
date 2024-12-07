import 'package:flutter/material.dart';

enum IzakayaCategory {
  nihonshu(
    id: 'nihonshu',
    name: '日本酒',
    keywords: ['日本酒', '地酒'],
    icon: Icons.rice_bowl,
  ),
  shochu(
    id: 'shochu',
    name: '焼酎',
    keywords: ['焼酎', '芋焼酎', '麦焼酎'],
    icon: Icons.local_drink,
  ),
  sashimi(
    id: 'sashimi',
    name: '刺身・海鮮',
    keywords: ['刺身', '海鮮', '魚'],
    icon: Icons.set_meal,
  ),
  yakitori(
    id: 'yakitori',
    name: '焼き鳥',
    keywords: ['焼き鳥', '焼鳥', 'やきとり'],
    icon: Icons.restaurant,
  ),
  oden(
    id: 'oden',
    name: 'おでん',
    keywords: ['おでん', 'オデン'],
    icon: Icons.soup_kitchen,
  );

  final String id;
  final String name;
  final List<String> keywords;
  final IconData icon;

  const IzakayaCategory({
    required this.id,
    required this.name,
    required this.keywords,
    required this.icon,
  });

  String toSearchKeyword() {
    return keywords.join(' ');
  }
} 