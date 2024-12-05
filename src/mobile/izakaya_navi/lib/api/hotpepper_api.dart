import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/venue.dart';
import '../models/hotpepper/shop.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/genre.dart';

class HotpepperApi {
  final String _baseUrl = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/';
  final String _apiKey;

  HotpepperApi({String? apiKey}) : _apiKey = apiKey ?? Env.hotpepperApiKey;

  /// キーワードによる店舗検索
  Future<List<Venue>> searchByKeyword(String keyword) async {
    // キーワードの特殊処理
    final Map<String, String> params = {
      'key': _apiKey,
      'format': 'json',
      'count': '100',
    };

    // 数字のみの場合は住所として検索
    if (RegExp(r'^\d+$').hasMatch(keyword)) {
      params['address'] = keyword;
    }
    // 駅名を含む場合は住所として検索
    else if (keyword.contains('駅')) {
      params['address'] = keyword;
    }
    // それ以外は通常のキーワード検索
    else {
      params['keyword'] = keyword;
    }

    return _fetchVenues(params);
  }

  /// 詳細条件による店舗検索
  Future<List<Venue>> searchByFilters({
    required Map<String, dynamic> params,
  }) async {
    // 基本パラメータを追加
    final searchParams = {
      'key': _apiKey,
      'format': 'json',
      'count': '100',
      ...params,
    };

    return _fetchVenues(searchParams);
  }

  /// 店舗詳細情報の取得
  Future<Venue?> getShopDetail(String id) async {
    final params = {
      'key': _apiKey,
      'id': id,
      'format': 'json',
    };

    final venues = await _fetchVenues(params);
    return venues.isNotEmpty ? venues.first : null;
  }

  /// ジャンル一覧の取得
  Future<List<Genre>> getGenres() async {
    final url = Uri.parse('http://webservice.recruit.co.jp/hotpepper/genre/v1/');
    final params = {
      'key': _apiKey,
      'format': 'json',
    };

    try {
      final response = await http.get(url.replace(queryParameters: params));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final genres = data['results']['genre'] as List;
        return genres.map((genre) => Genre.fromJson(genre)).toList();
      }
      throw HotpepperApiException('ジャンル情報の取得に失敗���ました');
    } catch (e) {
      throw HotpepperApiException('APIリクエスト中にエラーが発生しました: $e');
    }
  }

  /// エリア一覧の取得
  Future<List<Area>> getAreas() async {
    final url = Uri.parse('http://webservice.recruit.co.jp/hotpepper/small_area/v1/');
    final params = {
      'key': _apiKey,
      'format': 'json',
    };

    try {
      final response = await http.get(url.replace(queryParameters: params));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final areas = data['results']['small_area'] as List;
        return areas.map((area) => Area.fromJson(area)).toList();
      }
      throw HotpepperApiException('エリア情報の取得に失敗しました');
    } catch (e) {
      throw HotpepperApiException('APIリクエスト中にエラーが発生しました: $e');
    }
  }

  /// 店舗情報の取得共通処理
  Future<List<Venue>> _fetchVenues(Map<String, dynamic> params) async {
    final url = Uri.parse(_baseUrl);
    
    try {
      final response = await http.get(url.replace(queryParameters: params));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 検索結果の件数をログ
        final resultsAvailable = data['results']['results_available'];
        print('検索結果: $resultsAvailable 件');

        if (data['results']['shop'] == null) {
          print('検索結果なし');
          return [];
        }

        final shops = data['results']['shop'] as List;
        return shops.map((shop) => Shop.fromJson(shop).toVenue()).toList();
      }
      throw HotpepperApiException('店舗情報の取得に失敗しました: ${response.statusCode}');
    } catch (e) {
      print('APIエラー: $e');
      throw HotpepperApiException('APIリクエスト中にエラーが発生しました: $e');
    }
  }
}

class HotpepperApiException implements Exception {
  final String message;
  HotpepperApiException(this.message);

  @override
  String toString() => message;
} 