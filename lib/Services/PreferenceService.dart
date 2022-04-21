// ignore_for_file: file_names
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  void saveAuthStatus(bool authstatus) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('authStatus', authstatus);
  }

  Future<bool?> getAuthStatus() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('authStatus');
  }
}
