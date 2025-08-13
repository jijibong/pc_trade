import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpUtils {
  final Future<SharedPreferencesWithCache> _prefs =
      SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions(allowList: <String>{'counter'}));

  static Future<SharedPreferences> initSharedPreferences() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      print("SharedPreferences 损坏，尝试重置: $e");
      // 删除文件并重新初始化
      final prefsDir = await getApplicationSupportDirectory();
      final prefsFile = File('${prefsDir.path}/shared_preferences/trade.json');
      if (await prefsFile.exists()) {
        await prefsFile.delete();
      }
      return await SharedPreferences.getInstance();
    }
  }

  ///保存
  static Future set(String key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool?> getBool(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<int?> getInt(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<double?> getDouble(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  ///删除
  static remove(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  ///清空所有缓存
  static clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
