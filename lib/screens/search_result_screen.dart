import 'package:flutter/material.dart';
import '../widgets/store_card.dart';
import '../models/venue.dart';
import 'store_detail_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final List<Venue> venues;
  final String searchQuery;

  const SearchResultScreen({
    super.key,
    required this.venues,
    required this.searchQuery,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  static const int _itemsPerPage = 20;
  final ScrollController _scrollController = ScrollController();
  List<Venue> _displayedVenues = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoreItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreItems() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      final nextItems = widget.venues.skip(_displayedVenues.length).take(_itemsPerPage).toList();
      _displayedVenues.addAll(nextItems);
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        _displayedVenues.length < widget.venues.length) {
      _loadMoreItems();
    }
  }

  void _navigateToDetail(BuildContext context, Venue venue) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDetailScreen(venue: venue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.searchQuery}の検索結果'),
        centerTitle: true,
      ),
      body: widget.venues.isEmpty
          ? const Center(
              child: Text('検索結果が見つかりませんでした'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${widget.venues.length}件の検索結果',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayedVenues.length + (_displayedVenues.length < widget.venues.length ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _displayedVenues.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final venue = _displayedVenues[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: StoreCard(
                          venue: venue,
                          onTap: () => _navigateToDetail(context, venue),
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