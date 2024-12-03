import 'package:flutter/material.dart';
import '../widgets/store_card.dart';
import '../models/venue.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Venue> venues;
  final String searchQuery;

  const SearchResultScreen({
    super.key,
    required this.venues,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$searchQueryの検索結果'),
        centerTitle: true,
      ),
      body: venues.isEmpty
          ? const Center(
              child: Text('検索結果が見つかりませんでした'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                return StoreCard(
                  name: venue.name,
                  rating: venue.rating ?? 0.0,
                  imageUrl: '',  // 今回は画像表示は実装しない
                  categories: venue.types,
                  onTap: () {
                    // 後で店舗詳細画面に遷移する処理を追加
                  },
                );
              },
            ),
    );
  }
} 