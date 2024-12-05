import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/venue.dart';
import '../widgets/store_gallery.dart';

class StoreDetailScreen extends StatelessWidget {
  final Venue venue;

  const StoreDetailScreen({
    super.key,
    required this.venue,
  });

  Future<void> _launchMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${venue.location.latitude},${venue.location.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchHotpepper() async {
    if (venue.additionalDetails?['urls']?['pc'] == null) return;
    
    final url = Uri.parse(venue.additionalDetails!['urls']['pc'] as String);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchPhone() async {
    if (venue.phoneNumber == null) return;
    
    final url = Uri.parse('tel:${venue.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // アプリバー
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'store_${venue.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    venue.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              background: StoreGallery(venue: venue),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: お気に入り登録機能を実装
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('お気に入り機能は準備中です'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // 店舗情報
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 評価情報
                  if (venue.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          venue.rating.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (venue.reviewCount != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${venue.reviewCount}件)',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),

                  const SizedBox(height: 16),

                  // カャンル
                  if (venue.genres.isNotEmpty) ...[
                    const Text(
                      'ジャンル',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: venue.genres.map((genre) {
                        return Chip(
                          label: Text(genre),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 住所
                  if (venue.address != null) ...[
                    const Text(
                      '住所',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(venue.address!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: _launchMaps,
                        ),
                      ],
                    ),
                    if (venue.access != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        venue.access!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // 電話番号
                  if (venue.phoneNumber != null) ...[
                    const Text(
                      '電話番号',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(venue.phoneNumber!),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: _launchPhone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 営業時間
                  if (venue.open != null || venue.close != null) ...[
                    const Text(
                      '営業時間',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (venue.open != null)
                      Text('営業時間: ${venue.open}'),
                    if (venue.close != null) ...[
                      const SizedBox(height: 4),
                      Text('定休日: ${venue.close}'),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // 予算
                  if (venue.budget != null) ...[
                    const Text(
                      '予算',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(venue.budget!),
                    const SizedBox(height: 16),
                  ],

                  // ホットペッパーグルメのリンク
                  ElevatedButton.icon(
                    onPressed: _launchHotpepper,
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('ホットペッパーグルメで見る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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