import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:izakaya_navi/api/hotpepper_api.dart';
import 'package:izakaya_navi/models/venue.dart';
import 'hotpepper_api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('HotpepperApi', () {
    late HotpepperApi api;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      api = HotpepperApi(apiKey: 'test_api_key', client: mockClient);
    });

    test('searchByKeyword returns list of venues', () async {
      const keyword = '新宿 居酒屋';
      final response = {
        'results': {
          'shop': [
            {
              'id': 'J001234567',
              'name': 'テスト居酒屋',
              'address': '東京都新宿区西新宿1-1-1',
              'lat': '35.689722',
              'lng': '139.700278',
              'genre': {'name': '居酒屋'},
              'budget': {'name': '3000円〜4000円'},
              'photo': {'pc': {'l': 'http://example.com/photo.jpg'}},
            }
          ]
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(response)), 200),
      );

      final venues = await api.searchByKeyword(keyword);
      
      expect(venues, isA<List<Venue>>());
      expect(venues.length, 1);
      expect(venues.first.name, 'テスト居酒屋');
      expect(venues.first.placeId, 'J001234567');
    });

    test('searchByFilters applies all filters correctly', () async {
      final response = {
        'results': {
          'shop': [
            {
              'id': 'J001234567',
              'name': 'フィルターテスト居酒屋',
              'address': '東京都新宿区西新宿1-1-1',
              'lat': '35.689722',
              'lng': '139.700278',
              'genre': {'name': '居酒屋'},
              'budget': {'name': '3000円〜4000円'},
              'smoking': '禁煙',
              'party_capacity': '10〜20名',
              'private_room': 'あり',
              'free_drink': 'あり',
            }
          ]
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(response)), 200),
      );

      final venues = await api.searchByFilters(
        area: '新宿',
        partyCapacity: 15,
        smoking: '3',  // 禁煙
        privateRoom: true,
        freeDrink: true,
        budget: 'B011',  // 3001〜4000円
      );

      expect(venues, isA<List<Venue>>());
      expect(venues.length, 1);
      expect(venues.first.name, 'フィルターテスト居酒屋');
      expect(venues.first.placeId, 'J001234567');
    });

    test('getShopDetail returns venue details', () async {
      const shopId = 'J001234567';
      final response = {
        'results': {
          'shop': [
            {
              'id': shopId,
              'name': '詳細テスト居酒屋',
              'address': '東京都新宿区西新宿1-1-1',
              'lat': '35.689722',
              'lng': '139.700278',
              'genre': {'name': '居酒屋'},
              'budget': {'name': '3000円〜4000円'},
              'open': '17:00〜23:00',
              'close': '日曜日',
            }
          ]
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(response)), 200),
      );

      final venue = await api.getShopDetail(shopId);
      
      expect(venue, isNotNull);
      expect(venue?.placeId, shopId);
      expect(venue?.name, '詳細テスト居酒屋');
      expect(venue?.openingHours?.weekdayText?.first, '17:00〜23:00');
    });

    test('handles API error gracefully', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode({'error': 'Invalid request'})), 400),
      );

      expect(
        () => api.searchByKeyword('test'),
        throwsException,
      );
    });
  });
} 