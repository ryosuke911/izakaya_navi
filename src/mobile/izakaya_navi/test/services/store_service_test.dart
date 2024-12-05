import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:izakaya_navi/services/store_service.dart';
import 'package:izakaya_navi/services/location_service.dart';
import 'package:izakaya_navi/api/hotpepper_api.dart';
import 'package:izakaya_navi/models/venue.dart';
import 'package:izakaya_navi/models/location.dart';
import 'store_service_test.mocks.dart';

@GenerateMocks([HotpepperApi, LocationService])
void main() {
  late StoreService storeService;
  late MockHotpepperApi mockHotpepperApi;
  late MockLocationService mockLocationService;

  setUp(() {
    mockHotpepperApi = MockHotpepperApi();
    mockLocationService = MockLocationService();
    storeService = StoreService(
      hotpepperApi: mockHotpepperApi,
      locationService: mockLocationService,
    );
  });

  group('StoreService Tests', () {
    group('searchByKeyword', () {
      test('正常系: キーワード検索が成功する', () async {
        final expectedVenues = [
          Venue(id: '1', name: 'Test Venue 1', location: Location(latitude: 35.0, longitude: 135.0)),
          Venue(id: '2', name: 'Test Venue 2', location: Location(latitude: 35.1, longitude: 135.1)),
        ];

        when(mockHotpepperApi.searchByKeyword('渋谷 居酒屋'))
            .thenAnswer((_) async => expectedVenues);

        final result = await storeService.searchByKeyword('渋谷 居酒屋');
        expect(result, equals(expectedVenues));
        verify(mockHotpepperApi.searchByKeyword('渋谷 居酒屋')).called(1);
      });

      test('異常系: APIエラー時に例外をスローする', () async {
        when(mockHotpepperApi.searchByKeyword(any))
            .thenThrow(Exception('API Error'));

        expect(
          () => storeService.searchByKeyword('渋谷 居酒屋'),
          throwsA(isA<StoreServiceException>()),
        );
      });

      test('正常系: 空のリストが返される場合', () async {
        when(mockHotpepperApi.searchByKeyword('存在しない店舗'))
            .thenAnswer((_) async => []);

        final result = await storeService.searchByKeyword('存在しない店舗');

        expect(result, isEmpty);
        verify(mockHotpepperApi.searchByKeyword('存在しない店舗')).called(1);
      });
    });
  });
} 