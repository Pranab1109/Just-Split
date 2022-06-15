// ignore_for_file: file_names
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  Future<void> saveAuthStatus(bool authstatus) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('authStatus', authstatus);
  }

  Future<bool?> getAuthStatus() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool('authStatus');
  }

  //TODO: save userName AND avatar index
  Future<void> saveAvatarIndex(int? ind) async {
    final pref = await SharedPreferences.getInstance();
    if (ind == null) {
      await pref.remove('avatarInd');
    } else {
      await pref.setInt('avatarInd', ind);
    }
  }

  Future<int> getAvatarIndex() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt('avatarInd')!;
  }

  Future<void> saveAvatarName(String? name) async {
    final pref = await SharedPreferences.getInstance();
    if (name == null) {
      await pref.remove('name');
    } else {
      await pref.setString('name', name);
    }
  }

  Future<String> getAvatarName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('name') ?? "";
  }
}
