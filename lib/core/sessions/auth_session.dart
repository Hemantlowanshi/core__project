import 'package:core_project/core/services/recently_viewed_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static const String isLogin = 'is_login';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhoto = 'user_photo';

  static Future<void> saveLogin({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(isLogin, true);
    await prefs.setString(userName, name);
    await prefs.setString(userEmail, email);
    if (photoUrl != null) {
      await prefs.setString(userPhoto, photoUrl);
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(isLogin) ?? false;
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userName);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userEmail);
  }

  static Future<String?> getPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userPhoto);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(isLogin);
    await prefs.remove(userName);
    await prefs.remove(userEmail);
    await prefs.remove(userPhoto);

    await RecentlyViewedService.clear();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}
