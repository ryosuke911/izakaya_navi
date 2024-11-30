import 'package:supabase_flutter/supabase_flutter.dart';
import '../external_apis/fo.dart';

class StoreQueries {
  final SupabaseClient _supabase;

  StoreQueries(this._supabase);

  /// 店舗情報を取得
  Future<List<Map<String, dynamic>>> getStores({
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    var query = _supabase
        .from('stores')
        .select()
        .order('created_at', ascending: false);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.textSearch('name', searchQuery);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 20) - 1);
    }

    return await query;
  }

  /// 店舗詳細情報を取得
  Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    final response = await _supabase
        .from('stores')
        .select()
        .eq('id', storeId)
        .single();
    
    return response;
  }

  /// 店舗情報を作成
  Future<void> createStore({
    required String name,
    required String address,
    String? phoneNumber,
    String? businessHours,
    Map<String, dynamic>? additionalInfo,
  }) async {
    await _supabase.from('stores').insert({
      'name': name,
      'address': address,
      'phone_number': phoneNumber,
      'business_hours': businessHours,
      'additional_info': additionalInfo,
    });
  }

  /// 店舗情報を更新
  Future<void> updateStore({
    required String storeId,
    String? name,
    String? address,
    String? phoneNumber,
    String? businessHours,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final Map<String, dynamic> updates = {};
    
    if (name != null) updates['name'] = name;
    if (address != null) updates['address'] = address;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;
    if (businessHours != null) updates['business_hours'] = businessHours;
    if (additionalInfo != null) updates['additional_info'] = additionalInfo;

    await _supabase
        .from('stores')
        .update(updates)
        .eq('id', storeId);
  }

  /// 店舗を削除
  Future<void> deleteStore(String storeId) async {
    await _supabase
        .from('stores')
        .delete()
        .eq('id', storeId);
  }

  /// 近隣の店舗を検索
  Future<List<Map<String, dynamic>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    // PostgreSQLの地理空間クエリを使用
    final response = await _supabase
        .rpc('get_nearby_stores', params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusInKm,
        });
    
    return List<Map<String, dynamic>>.from(response);
  }
}