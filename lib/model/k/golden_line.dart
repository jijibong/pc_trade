class GoldenLine {
  /**商品代码*/
   String code='';
  /**线的位置标记，0--K线 ， 1--RSI,DMI, 2--MACD*/
   int flag=0;
  /**开始点日期*/
   String startDate='';
  /**开始位置的价格*/
   double startPrice=0;
  /**结束点日期*/
   String endDate='';
  /**结束位置的价格*/
   double endPrice=0;
  /**是否被选中*/
   bool isSelect=false;
  /**被选中的点 -1 ---无 0---起点 1---中点 2---终点*/
   int selectPoint=-1;

  }