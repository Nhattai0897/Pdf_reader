import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences prefs;
  //SharedPrefs.internal();
  //Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static initializer() async {
    prefs = await SharedPreferences.getInstance();
  }

  ///get dynamic
  T? getValue<T>(KeyPrefs key) {
    try {
      var result = prefs.get(key.toString());
      return result != null ? result as T : null;
    } catch (error) {
      throw (error);
    }
  }

  ///set dynamic
  setValue<T>(KeyPrefs key, dynamic value) {
    try {
      switch (T) {
        case int:
          prefs.setInt(key.toString(), value);
          break;
        case String:
          prefs.setString(key.toString(), value);
          break;
        case double:
          prefs.setDouble(key.toString(), value);
          break;
        case bool:
          prefs.setBool(key.toString(), value);
          break;
        default:
          prefs.setString(key.toString(), value);
          break;
      }
    } catch (error) {
      throw (error);
    }
  }
}

enum KeyPrefs {
  /// type: string
  localeCode,

  /// type: bool
  isFirst
}
