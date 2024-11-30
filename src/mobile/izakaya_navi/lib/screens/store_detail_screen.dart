import 'package:flutter/material.dart';
import '../widgets/store_gallery.dart';

class StoreDetailScreen extends StatelessWidget {
  const StoreDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ダミーデータ
    final Map<String, dynamic> store = {
      'name': '居酒屋 さくら',
      'rating': 4.5,
      'images': <String>[],  // 実際の画像URLを追加
      'budget': '3,000円～4,000円',
      'address': '東京都渋谷区道玄坂2-1-1',
      'tel': '03-1234-5678',
      'businessHours': '17:00～23:00',
      'holidays': '日曜日',
      'features': [
        '個室あり',
        '飲み放題あり',
        '食べ放題あり',
        'カード可',
        '禁煙',
      ],
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // アプリバー
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: StoreGallery(images: store['images']),
            ),
          ),

          // 店舗情報
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 店舗名と評価
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          store['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            store['rating'].toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 予算
                  _buildInfoRow(
                    Icons.wallet,
                    '予算',
                    store['budget'],
                  ),
                  const SizedBox(height: 8),

                  // 住所
                  _buildInfoRow(
                    Icons.location_on,
                    '住所',
                    store['address'],
                  ),
                  const SizedBox(height: 8),

                  // 電話番号
                  _buildInfoRow(
                    Icons.phone,
                    '電話番号',
                    store['tel'],
                  ),
                  const SizedBox(height: 8),

                  // 営業時間
                  _buildInfoRow(
                    Icons.access_time,
                    '営業時間',
                    store['businessHours'],
                  ),
                  const SizedBox(height: 8),

                  // 定休日
                  _buildInfoRow(
                    Icons.calendar_today,
                    '定休日',
                    store['holidays'],
                  ),
                  const SizedBox(height: 16),

                  // 特徴
                  const Text(
                    '特徴',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: store['features'].map<Widget>((feature) {
                      return Chip(
                        label: Text(feature),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 予約ボタン
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              // TODO: 予約機能の実装
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '予約する',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}