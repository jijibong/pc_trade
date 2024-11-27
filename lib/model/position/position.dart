
 class PositionType {
  //无
   static const int POSITION_NONE  = 0;
  //今仓
   static const int POSITION_TODAY  = 1;
  //昨仓
   static const int POSITION_YESTODAY  = 2;

   static int getType(String str){
    int type = POSITION_NONE;
    switch (str){
      case "不分":
        type = POSITION_NONE;
        break;

      case "今仓":
        type = POSITION_TODAY;
        break;

      case "昨仓":
        type = POSITION_YESTODAY;
        break;
    }

    return type;
  }

   static String getName(int type){
    String name = "---";
    switch (type){
      case POSITION_NONE:
        name = "---";
        break;

      case POSITION_TODAY:
        name = "今仓";
        break;

      case POSITION_YESTODAY:
        name = "昨仓";
        break;
    }

    return name;
  }
}
