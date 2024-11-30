import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthFunctions {
  final SupabaseClient _supabaseClient;

  SupabaseAuthFunctions(this._supabaseClient);

  // サインアップ
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('サインアップに失敗しました: $error');
    }
  }

  // メール・パスワードでサインイン
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('サインインに失敗しました: $error');
    }
  }

  // サインアウト
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (error) {
      throw Exception('サインアウトに失敗しました: $error');
    }
  }

  // 現在のユーザーを取得
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  // パスワードリセットメールを送信
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('パスワードリセットメールの送信に失敗しました: $error');
    }
  }

  // セッションの状態を監視
  Stream<AuthState> authStateChanges() {
    return _supabaseClient.auth.onAuthStateChange;
  }

  // パスワードの更新
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (error) {
      throw Exception('パスワードの更新に失敗しました: $error');
    }
  }

  // ユーザープロファイルの更新
  Future<void> updateProfile({
    String? username,
    String? avatarUrl,
  }) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            if (username != null) 'username': username,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );
    } catch (error) {
      throw Exception('プロファイルの更新に失敗しました: $error');
    }
  }

  // セッションの有効性を確認
  bool isSessionValid() {
    final session = _supabaseClient.auth.currentSession;
    return session != null && !session.isExpired;
  }
}
final supabaseClient = SupabaseClient('YOUR_SUPABASE_URL', 'YOUR_SUPABASE_ANON_KEY');
final authFunctions = SupabaseAuthFunctions(supabaseClient);