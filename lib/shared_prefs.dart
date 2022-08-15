import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  readObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    // print(prefs.getString(key));
    return json.decode(prefs.getString(key)??'{}');
  }

  saveObject(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
    // print(prefs.getString(key));
  }
  saveString(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}