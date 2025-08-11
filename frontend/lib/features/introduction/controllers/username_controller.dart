import 'package:shared_preferences/shared_preferences.dart';

class UsernameController {

  static Future<void> setUsername(String username) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  static Future<String?> getUsername() async{
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username;
  }
}