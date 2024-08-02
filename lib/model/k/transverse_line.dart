class TransverseLine {
  /**商品代码*/
  String code='';
  /**线的位置标记，0--K线 ， 1--RSI,DMI, 2--MACD*/
  int flag=0;
  /**当前位置的价格*/
  double price=0;
  /**是否被选中*/
  bool isSelect= false;

}
