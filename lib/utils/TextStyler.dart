import 'package:flutter/cupertino.dart';
import 'package:just_split/utils/Cooloors.dart';

Cooloors cooloors = Cooloors();

class TextStyles {
  TextStyle lightBoldTextStyle =
      TextStyle(color: cooloors.lightTextColor, fontWeight: FontWeight.bold);
  TextStyle lightNormalTextStyle =
      TextStyle(color: cooloors.lightTextColor, fontWeight: FontWeight.normal);
  TextStyle lightSemiTextStyle =
      TextStyle(color: cooloors.lightTextColor, fontWeight: FontWeight.w500);

  TextStyle darkBoldTextStyle =
      TextStyle(color: cooloors.darkTextColor, fontWeight: FontWeight.bold);
  TextStyle darkNormalTextStyle =
      TextStyle(color: cooloors.darkTextColor, fontWeight: FontWeight.normal);
  TextStyle darkSemiTextStyle =
      TextStyle(color: cooloors.darkTextColor, fontWeight: FontWeight.w500);
}
