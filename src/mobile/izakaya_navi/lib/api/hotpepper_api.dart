import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../models/venue.dart';
import '../models/hotpepper/shop.dart';
import '../models/hotpepper/area.dart';
import '../models/hotpepper/genre.dart';

class HotpepperApi {
  static const String _gourmetUrl = 'https://160.17.98.51/hotpepper/gourmet/v1/';
  static const String _middleAreaUrl = 'https://160.17.98.51/hotpepper/middle_area/v1/';
  final String _apiKey;
  final http.Client _client;
  
  HotpepperApi({
    String? apiKey,
    http.Client? client,
  }) : _apiKey = apiKey ?? Env.hotpepperApiKey,
       _client = client ?? _createClient() {
    print('Initialized HotpepperApi with key: ${_apiKey.substring(0, 4)}...');
  }

  static http.Client _createClient() {
    if (kDebugMode) {
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return IOClient(httpClient);
    }
    return http.Client();
  }

  /// 中エリア一覧の取得
  /// アプリ起動時に一度だけ呼び出し、以降はインメモリでデータを管理する
  Future<MiddleAreaList> getMiddleAreas() async {
    final url = Uri.parse(_middleAreaUrl);
    final params = {
      'key': _apiKey,
      'format': 'json',
    };

    try {
      final requestUrl = url.replace(queryParameters: params);
      print('=== エリアデータ取得リクエスト ===');
      print('URL: ${requestUrl.toString()}');
      
      final response = await _client.get(requestUrl);
      
      print('=== エリアデータ取得レスポンス ===');
      print('ステータスコード: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('エリアデータ: ${data['results']['middle_area']}');
        
        final areas = data['results']['middle_area'] as List;
        print('エリア数: ${areas.length}');
        print('最初の5つのエリア:');
        for (var i = 0; i < 5 && i < areas.length; i++) {
          print('- ${areas[i]['name']}');
        }
        
        final middleAreas = areas.map((area) => MiddleArea.fromJson(area)).toList();
        return MiddleAreaList(middleAreas);
      }
      
      throw HotpepperApiException('中エリア情報の取得に失敗しました: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('エリアデータ取得エラー: $e');
      print('スタックトレース: $stackTrace');
      throw HotpepperApiException('APIリクエスト中にエラーが発生しました: $e');
    }
  }

  /// エリアコードによる店舗検索
  Future<List<Venue>> searchByArea(String areaCode, {Map<String, String>? additionalParams}) async {
    final url = Uri.parse(_gourmetUrl);
    final params = {
      'key': _apiKey,
      'format': 'json',
      'count': '100',
      'middle_area': areaCode,
      ...?additionalParams,
    };

    try {
      final response = await _client.get(url.replace(queryParameters: params));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
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

  /// APIクライアントの破棄
  void dispose() {
    _client.close();
  }
}

class HotpepperApiException implements Exception {
  final String message;
  HotpepperApiException(this.message);

  @override
  String toString() => message;
} 