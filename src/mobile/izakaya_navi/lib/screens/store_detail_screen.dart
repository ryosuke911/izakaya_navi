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
      'https://www.google.com/maps/search/?api=1&query=${venue.location.lat},${venue.location.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWebsite() async {
    if (venue.website == null) return;
    
    final url = Uri.parse(venue.website!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchPhone() async {
    if (venue.formattedPhoneNumber == null) return;
    
    final url = Uri.parse('tel:${venue.formattedPhoneNumber}');
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
                tag: 'store_${venue.placeId}',
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
              background: venue.photos != null && venue.photos!.isNotEmpty
                  ? StoreGallery(photos: venue.photos!)
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
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
                        if (venue.userRatingsTotal != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${venue.userRatingsTotal}件)',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),

                  const SizedBox(height: 16),

                  // カテゴリー
                  if (venue.types.isNotEmpty) ...[
                    const Text(
                      'カテゴリー',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: venue.types.map((type) {
                        return Chip(
                          label: Text(type),
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 住所
                  if (venue.vicinity != null) ...[
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
                          child: Text(venue.vicinity!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.map),
                          onPressed: _launchMaps,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 電話番号
                  if (venue.formattedPhoneNumber != null) ...[
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
                        Text(venue.formattedPhoneNumber!),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: _launchPhone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 営業時間
                  if (venue.openingHours != null) ...[
                    const Text(
                      '営業時間',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      venue.openingHours!.openNow ? '営業中' : '営業時間外',
                      style: TextStyle(
                        color: venue.openingHours!.openNow ? Colors.green : Colors.red,
                      ),
                    ),
                    if (venue.openingHours!.weekdayText != null) ...[
                      const SizedBox(height: 8),
                      ...venue.openingHours!.weekdayText!.map((text) => Text(text)),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // ウェブサイト
                  if (venue.website != null) ...[
                    const Text(
                      'ウェブサイト',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _launchWebsite,
                      child: Text(venue.website!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}