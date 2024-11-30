import 'package:flutter/material.dart';
import '../widgets/store_card.dart';
import 'store_detail_screen.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  bool _isMapView = false;

  // ダミーデータ
  final List<Map<String, dynamic>> _dummyStores = [
    {
      'name': '居酒屋 さくら',
      'address': '東京都渋谷区道玄坂2-1-1',
      'imageUrl': '',
      'budget': '3,000円～4,000円',
      'rating': 4.5,
    },
    {
      'name': '炉端焼き 大漁',
      'address': '東京都渋谷区神南1-1-1',
      'imageUrl': '',
      'budget': '4,000円～5,000円',
      'rating': 4.2,
    },
    {
      'name': '個室居酒屋 和み',
      'address': '東京都渋谷区宇田川町1-1-1',
      'imageUrl': '',
      'budget': '5,000円～6,000円',
      'rating': 4.7,
    },
    {
      'name': '海鮮居酒屋 うみ',
      'address': '東京都渋谷区神南2-1-1',
      'imageUrl': '',
      'budget': '3,500円～4,500円',
      'rating': 4.0,
    },
    {
      'name': '焼き鳥 とり吉',
      'address': '東京都渋谷区神南3-1-1',
      'imageUrl': '',
      'budget': '2,500円～3,500円',
      'rating': 4.3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('検索結果'),
        centerTitle: true,
        actions: [
          // 表示切り替えボタン
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索結果数
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  '${_dummyStores.length}件の居酒屋が見つかりました',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 検索結果表示（リスト/マップ）
          Expanded(
            child: _isMapView
                ? Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text('地図表示（実装予定）'),
                    ),
                  )
                : ListView.builder(
                    itemCount: _dummyStores.length,
                    itemBuilder: (context, index) {
                      final store = _dummyStores[index];
                      return StoreCard(
                        name: store['name'],
                        address: store['address'],
                        imageUrl: store['imageUrl'],
                        budget: store['budget'],
                        rating: store['rating'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StoreDetailScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}