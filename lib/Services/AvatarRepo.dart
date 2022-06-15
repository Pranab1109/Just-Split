import 'package:just_split/Services/PreferenceService.dart';

class AvatarRepo {
  int selectedAvatar = 1;
  PreferenceService preferenceService = PreferenceService();
  String userName = "";
  void selectIndex(int index) async {
    preferenceService.saveAvatarIndex(index);
    selectedAvatar = index;
  }

  void selectUserName(String name) {
    preferenceService.saveAvatarName(name);
    userName = name;
  }

  dynamic getSelectedAvatar() async {
    int ind = await preferenceService.getAvatarIndex();
    String name = await preferenceService.getAvatarName();
    return {
      "ind": ind,
      "name": name,
    };
  }
}
