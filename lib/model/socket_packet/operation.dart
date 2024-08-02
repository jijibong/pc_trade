class Operation {
  /**发送认证信息*/
  static const int SendAuth = 10;
  /**认证信息返回*/
  static const int AuthRes = 11;
  /**发送心跳*/
  static const int SendHeart = 12;
  /**心跳反馈*/
  static const int HeartRes = 13;
  /**订阅*/
  static const int SendSub = 14;
  /**取消订阅*/
  static const int UnSendSub = 140;
  /**订阅反馈*/
  static const int SubRes = 15;
  /**行情变化通知*/
  static const int RevQuote = 16;
  /**K线变化通知*/
  static const int RevKline = 17;
//    /**订阅持仓浮动盈亏*/
//     static const int SendSubPosFloat = 18;
//    /**取消订阅持仓浮动盈亏*/
//     static const int SendUnSubPosFloat = 19;
//    /**订阅总浮动盈亏*/
//     static const int SendSubTotalFloat = 20;
//    /**取消订阅总浮动盈亏*/
//     static const int SendUnSubTotalFloat = 21;
  /**成交逐笔推送*/
  static const int RecvFillData = 22;
  /**订阅成交逐笔*/
  static const int SendSubFillData = 23;
  /**订阅成交逐笔反馈*/
  static const int RecvSubFillData = 24;
  /**取消订阅成交逐笔*/
  static const int SendUnSubFillData = 25;
  /**取消订阅成交逐笔反馈*/
  static const int RecvUnSubFillData = 26;
  /**订阅K线*/
  static const int RecvSubKlineData = 27;
  /**取消订阅K线*/
  static const int RecvUnSubKlineData = 28;
  /**服务器主动断开通知*/
  static const int RevSclose = 100;
  /**登出成功*/
  static const int RevLoginOut = 58;
//    /**订单状态改变*/
//     static const int RevOrderState = 59;
//    /**订单成交*/
//     static const int RevOrderTrans = 60;
//    /**新增持仓信息*/
//     static const int RevPositionAdd = 61;
//    /**持仓盈亏*/
//     static const int RevProfitLoss = 62;
//    /**持仓变化*/
//     static const int RevPositionChange = 63;
//    /**平仓新增*/
//     static const int RevCloseAdd = 64;
//    /**汇率*/
//     static const int RevExchangeRate = 65;
//    /**冻结资金变化*/
//     static const int RevFreezeChange = 67;
//    /**资金变化*/
//     static const int RevFund = 69;
//    /**总浮盈变化*/
//     static const int RevAllFloat = 70;
}
