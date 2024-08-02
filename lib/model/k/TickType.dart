/**
 * @Descrption 逐笔成交tick数据性质
 * @Author hexuejian
 * @Time 2019/5/17 14:10
 */
 class TickType {
   static const int OPENLONG = 0; //多开
   static const int OPENSHORT = 1; //空开
   static const int OPENDOUBLE = 2; //双开

   static const int CLOSELONG = 3;//多平
   static const int CLOSESHORT = 4; //空开
   static const int CLOSEDOUBLE = 5; //双开

   static const int EXCHANGELONG = 6; //多换
   static const int EXCHANGESHORT = 7; //空换

   static const int OPENUNKOWN = 8;  //开仓
   static const int CLOSEUNKOWN = 9;  //平仓
   static const int EXCHANGEUNKOWN = 10; //换仓
   static const int UNKOWN = 11; //未知
   static const int NOCHANGE = 12; //没有变化


   static String getName(int type){
    String name = "";
    switch (type){
      case OPENLONG:
        name =  "多开";
        break;

      case OPENSHORT: //
        name =  "空开";
        break;

      case OPENDOUBLE: //
        name =  "双开";
        break;

      case CLOSELONG: //
        name =  "多平";
        break;

      case CLOSESHORT: //
        name =  "空平";
        break;

      case CLOSEDOUBLE: //
        name =  "双平";
        break;

      case EXCHANGELONG: //
        name =  "多换";
        break;

      case EXCHANGESHORT: //
        name =  "空换";
        break;

      case OPENUNKOWN: //
        name =  "开仓";
        break;

      case CLOSEUNKOWN: //
        name =  "平仓";
        break;

      case EXCHANGEUNKOWN: //
        name =  "换仓";
        break;

      case UNKOWN: //
        name =  "---";
        break;

      case NOCHANGE: //---
        name ="---";
        break;
    }

    return name;
  }
}
