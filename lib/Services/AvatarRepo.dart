class AvatarRepo {
  int selectedAvatar = 1;
  void selectIndex(int index) {
    selectedAvatar = index;
  }

  int getSelectedAvatar() {
    return selectedAvatar;
  }
}
