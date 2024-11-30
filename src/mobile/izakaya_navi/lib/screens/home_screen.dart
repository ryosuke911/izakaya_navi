import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_buttons.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('居酒屋Navi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // カスタム検索バー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomSearchBar(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // カテゴリーボタン
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CategoryButtons(),
          ),
          const SizedBox(height: 24),
          // おすすめ店舗セクション
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'おすすめの居酒屋',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant),
                            ),
                            title: Text('居酒屋 ${index + 1}'),
                            subtitle: const Text('場所: 東京都渋谷区'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // 店舗詳細画面への遷移（後で実装）
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}