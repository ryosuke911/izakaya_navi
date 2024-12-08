import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:izakaya_navi/api/hotpepper_api.dart';
import 'package:izakaya_navi/models/venue.dart';
import 'package:izakaya_navi/models/hotpepper/area.dart';
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

    test('getMiddleAreas returns list of middle areas', () async {
      final response = {
        'results': {
          'middle_area': [
            {
              'code': 'MA001',
              'name': '渋谷',
            },
            {
              'code': 'MA002',
              'name': '新宿',
            }
          ]
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(response)), 200),
      );

      final areaList = await api.getMiddleAreas();
      
      expect(areaList, isA<MiddleAreaList>());
      expect(areaList.areas.length, 2);
      expect(areaList.areas.first.name, '渋谷');
      expect(areaList.areas.first.code, 'MA001');
    });

    test('searchByArea returns list of venues', () async {
      const areaCode = 'MA001';
      final response = {
        'results': {
          'shop': [
            {
              'id': 'J001234567',
              'name': 'テスト居酒屋',
              'address': '東京都渋谷区道玄坂1-1-1',
              'lat': '35.658034',
              'lng': '139.701636',
              'genre': {'name': '居酒屋'},
              'budget': {'name': '3000円〜4000円'},
              'photo': {'pc': {'l': 'http://example.com/photo.jpg'}},
              'middle_area': {
                'code': 'MA001',
                'name': '渋谷',
              }
            }
          ],
          'results_available': 1
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(response)), 200),
      );

      final venues = await api.searchByArea(areaCode);
      
      expect(venues, isA<List<Venue>>());
      expect(venues.length, 1);
      expect(venues.first.name, 'テスト居酒屋');
      expect(venues.first.id, 'J001234567');
      expect(venues.first.area?.code, 'MA001');
      expect(venues.first.area?.name, '渋谷');
    });

    test('handles API error gracefully', () async {
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode({'error': 'Invalid request'})), 400),
      );

      expect(
        () => api.getMiddleAreas(),
        throwsA(isA<HotpepperApiException>()),
      );
    });

    test('handles empty results correctly', () async {
      final response = {
        'results': {
          'shop': null,
          'results_available': 0
        }
      };

      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(jsonEncode(response)), 200),
      );

      final venues = await api.searchByArea('MA001');
      expect(venues, isEmpty);
    });
  });
} 