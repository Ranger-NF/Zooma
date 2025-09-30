import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {


  static Future<void> saveToken({required String tokenKey,required String tokenValue}) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, tokenValue);
  }

  static Future<String?> getToken(String tokenKey) async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> removeToken(String tokenKey) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}