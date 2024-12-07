import 'package:flutter/material.dart';
import '../widgets/store_card.dart';
import '../models/venue.dart';
import '../models/hotpepper/search_params.dart';
import '../models/hotpepper/izakaya_category.dart';
import 'store_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Venue> venues;
  final SearchParams searchParams;

  const SearchResultScreen({
    super.key,
    required this.venues,
    required this.searchParams,
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

  Widget _buildSearchConditions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchParams.keyword != null) ...[
            Text('キーワード: ${searchParams.keyword}'),
            const SizedBox(height: 4),
          ],
          if (searchParams.area != null) ...[
            Text('エリア: ${searchParams.area!.name}'),
            const SizedBox(height: 4),
          ],
          if (searchParams.categories.isNotEmpty) ...[
            Text('カテゴリ: ${searchParams.categories.map((c) => c.name).join(', ')}'),
            const SizedBox(height: 4),
          ],
          if (searchParams.budget != null) ...[
            Text(
              '予算: ${searchParams.budget!.min ?? ''}円 〜 ${searchParams.budget!.max ?? ''}円',
            ),
            const SizedBox(height: 4),
          ],
          if (searchParams.partySize != null) ...[
            Text('人数: ${searchParams.partySize}人'),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              if (searchParams.hasPrivateRoom ?? false)
                _buildConditionChip('個室あり'),
              if (searchParams.hasFreedrink ?? false)
                _buildConditionChip('飲み放題あり'),
              if (searchParams.openNow ?? false)
                _buildConditionChip('現在営業中'),
              if (searchParams.lateNight ?? false)
                _buildConditionChip('深夜営業'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.white,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildEmptyResult(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '検索結果が見つかりませんでした',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '検索条件を変更して、もう一度お試しください',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('検索条件を変更'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('検索結果（${venues.length}件）'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchConditions(),
          Expanded(
            child: venues.isEmpty
                ? _buildEmptyResult(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: venues.length,
                    itemBuilder: (context, index) {
                      final venue = venues[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Hero(
                          tag: 'store_${venue.id}',
                          child: Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                            child: StoreCard(
                              venue: venue,
                              onTap: () => _navigateToDetail(context, venue),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}