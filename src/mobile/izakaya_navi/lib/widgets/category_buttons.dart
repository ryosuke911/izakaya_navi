import 'package:flutter/material.dart';

class CategoryButtons extends StatelessWidget {
  const CategoryButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16.0),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      children: [
        _buildCategoryButton(
          icon: Icons.restaurant,
          label: '和食',
          onTap: () {
            // TODO: 和食カテゴリの処理
          },
        ),
        _buildCategoryButton(
          icon: Icons.local_bar,
          label: '居酒屋',
          onTap: () {
            // TODO: 居酒屋カテゴリの処理
          },
        ),
        _buildCategoryButton(
          icon: Icons.ramen_dining,
          label: 'ラーメン',
          onTap: () {
            // TODO: ラーメンカテゴリの処理
          },
        ),
        _buildCategoryButton(
          icon: Icons.set_meal,
          label: '焼肉',
          onTap: () {
            // TODO: 焼肉カテゴリの処理
          },
        ),
        _buildCategoryButton(
          icon: Icons.lunch_dining,
          label: '洋食',
          onTap: () {
            // TODO: 洋食カテゴリの処理
          },
        ),
        _buildCategoryButton(
          icon: Icons.more_horiz,
          label: 'その他',
          onTap: () {
            // TODO: その他カテゴリの処理
          },
        ),
      ],
    );
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32.0,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}