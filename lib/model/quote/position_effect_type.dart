class PositionEffectType {
  //不分开平
  static const int PositionEffect_NONE = 78;
  //开仓
  static const int PositionEffect_OPEN = 79;
  //平仓
  static const int PositionEffect_COVER = 67;
  //平当日
  static const int PositionEffect_COVER_TODAY = 84;

  static String getName(int? oc) {
    String name = "";
    switch (oc) {
      case PositionEffect_NONE:
        name = "自动";
        break;

      case PositionEffect_OPEN:
        name = "开仓";
        break;

      case PositionEffect_COVER:
        name = "平仓";
        break;

      case PositionEffect_COVER_TODAY:
        name = "平今";
        break;
    }
    return name;
  }

  static String getShortName(int? oc) {
    String name = "";
    switch (oc) {
      case PositionEffect_NONE:
        name = "";
        break;

      case PositionEffect_OPEN:
        name = "开";
        break;

      case PositionEffect_COVER:
        name = "平";
        break;

      case PositionEffect_COVER_TODAY:
        name = "平今";
        break;
    }
    return name;
  }
}
