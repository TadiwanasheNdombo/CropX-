import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token saved: $token'); // Debug log
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('Retrieved token: $token'); // Debug log
    return token;
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
    print('Refresh token saved: $token'); // Debug log
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_refreshTokenKey);
    print('Retrieved refresh token: $token'); // Debug log
    return token;
  }

  static Future<void> saveTokenExpiry(int expiry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenExpiryKey, expiry);
    print('Token expiry saved: $expiry'); // Debug log
  }

  static Future<int?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_tokenExpiryKey);
    print('Retrieved token expiry: $expiry'); // Debug log
    return expiry;
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    print('User ID saved: $userId'); // Debug log
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    print('Retrieved user ID: $userId'); // Debug log
    return userId;
  }

  static Future<bool> isTokenValid() async {
    final expiry = await getTokenExpiry();
    final isValid =
        expiry != null && DateTime.now().millisecondsSinceEpoch < expiry;
    print('Is token valid: $isValid'); // Debug log
    return isValid;
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
    await prefs.remove(_userIdKey);
    print('Cleared authentication data'); // Debug log
  }
}
