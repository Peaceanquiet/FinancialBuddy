import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> setLoggedIn(bool isLoggedIn) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', isLoggedIn);
}

Future<bool> checkLoggedIn() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

Future<void> savePrefs(String uname, Map<String, dynamic> preferences) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_name', uname);
  String preferencesString = jsonEncode(preferences);
  await prefs.setString('user_preferences', preferencesString);
}

Future<Map<String, dynamic>> loadPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  String? uname = prefs.getString('user_name');
  String? preferencesString = prefs.getString('user_preferences');
  Map<String, dynamic>? preferences = preferencesString != null
      ? jsonDecode(preferencesString)
      : null;

  return {'user_name': uname, 'preferences': preferences};
}
