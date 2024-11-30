import 'package:izakaya_navi/src/backend/supabase/favorite_queries.dart';

/// お気に入り店舗を管理するサービスクラス
class FavoriteService {
  final FavoriteQueries _favoriteQueries;

  FavoriteService({
    FavoriteQueries? favoriteQueries,
  }) : _favoriteQueries = favoriteQueries ?? FavoriteQueries();

  /// 指定した店舗をお気に入りに追加
  Future<void> addFavorite({
    required String userId,
    required String izakayaId,
  }) async {
    try {
      await _favoriteQueries.insertFavorite(
        userId: userId,
        izakayaId: izakayaId,
      );
    } catch (e) {
      throw Exception('お気に入りの追加に失敗しました: $e');
    }
  }

  /// 指定した店舗をお気に入りから削除
  Future<void> removeFavorite({
    required String userId,
    required String izakayaId,
  }) async {
    try {
      await _favoriteQueries.deleteFavorite(
        userId: userId,
        izakayaId: izakayaId,
      );
    } catch (e) {
      throw Exception('お気に入りの削除に失敗しました: $e');
    }
  }

  /// ユーザーのお気に入り店舗一覧を取得
  Future<List<String>> getFavoriteIzakayaIds(String userId) async {
    try {
      return await _favoriteQueries.getFavoriteIzakayaIds(userId);
    } catch (e) {
      throw Exception('お気に入り店舗の取得に失敗しました: $e');
    }
  }

  /// 指定した店舗がお気に入りに登録されているか確認
  Future<bool> isFavorite({
    required String userId,
    required String izakayaId,
  }) async {
    try {
      return await _favoriteQueries.checkFavoriteExists(
        userId: userId,
        izakayaId: izakayaId,
      );
    } catch (e) {
      throw Exception('お気に入り状態の確認に失敗しました: $e');
    }
  }

  /// お気に入り店舗の件数を取得
  Future<int> getFavoriteCount(String userId) async {
    try {
      return await _favoriteQueries.getFavoriteCount(userId);
    } catch (e) {
      throw Exception('お気に入り件数の取得に失敗しました: $e');
    }
  }
}