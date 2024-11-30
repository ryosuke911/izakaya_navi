import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../backend/supabase/auth_functions.dart';

class AuthService {
  final SupabaseClient _supabaseClient;
  
  AuthService(this._supabaseClient);

  // 現在のユーザーを取得
  User? get currentUser => _supabaseClient.auth.currentUser;

  // メールアドレスとパスワードでサインアップ
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      return response;
    } catch (e) {
      throw AuthException('サインアップに失敗しました: $e');
    }
  }

  // メールアドレスとパスワードでサインイン
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
    } catch (e) {
      throw AuthException('サインインに失敗しました: $e');
    }
  }

  // サインアウト
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('サインアウトに失敗しました: $e');
    }
  }

  // パスワードリセットメールの送信
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('パスワードリセットメールの送信に失敗しました: $e');
    }
  }

  // パスワードの更新
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('パスワードの更新に失敗しました: $e');
    }
  }

  // ユーザー情報の更新
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    try {
      await _supabaseClient.auth.updateUser(
        UserAttributes(data: userData),
      );
    } catch (e) {
      throw AuthException('ユーザー情報の更新に失敗しました: $e');
    }
  }

  // 認証状態の監視
  Stream<AuthState> authStateChanges() {
    return _supabaseClient.auth.onAuthStateChange;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}