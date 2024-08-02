import 'package:shared_preferences/shared_preferences.dart';

class SpUtils {
  ///保存
  static Future set(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is List) {
      prefs.setStringList(key, value.cast<String>());
    }
  }

  ///获取
  static Future<String?> getString(String key) async {
    var sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  static Future<bool?> getBool(String key) async {
    var sp = await SharedPreferences.getInstance();
    return sp.getBool(key);
  }

  static Future<int?> getInt(String key) async {
    var sp = await SharedPreferences.getInstance();
    return sp.getInt(key);
  }

  static Future<double?> getDouble(String key) async {
    var sp = await SharedPreferences.getInstance();
    return sp.getDouble(key);
  }

  ///删除
  static remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  ///清空所有缓存
  static clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
