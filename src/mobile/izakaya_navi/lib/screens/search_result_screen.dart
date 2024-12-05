import 'package:flutter/material.dart';
import '../widgets/store_card.dart';
import '../models/venue.dart';
import 'store_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Venue> venues;
  final String searchQuery;

  const SearchResultScreen({
    super.key,
    required this.venues,
    required this.searchQuery,
  });

  void _navigateToDetail(BuildContext context, Venue venue) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoreDetailScreen(venue: venue),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('店舗詳細の表示に失敗しました。もう一度お試しください。'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Hero(
                    tag: 'store_${venue.id}',
                    child: Material(
                      child: StoreCard(
                        venue: venue,
                        onTap: () => _navigateToDetail(context, venue),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}