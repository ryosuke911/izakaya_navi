import '../api/places_api.dart';
import '../models/venue.dart';

class StoreService {
  final PlacesApi _placesApi;

  StoreService({PlacesApi? placesApi}) : _placesApi = placesApi ?? PlacesApi();

  // エリアまたは駅名で店舗を検索
  Future<List<Venue>> searchByArea(String query) async {
    print('StoreService.searchByArea called with query: $query');

    if (query.isEmpty) {
      print('Empty query, returning empty list');
      return [];
    }

    // 検索クエリに「居酒屋」を追加して検索
    final searchQuery = '$query 居酒屋';
    print('Modified search query: $searchQuery');

    try {
      final results = await _placesApi.searchByText(searchQuery);
      print('Search results count: ${results.length}');
      return results;
    } catch (e, stackTrace) {
      print('Error in searchByArea: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
} 