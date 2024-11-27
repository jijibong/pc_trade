class OrderState {
  //指令失败
  static const int ORDER_STATE_FAIL = 48;
  //订单处理中
  static const int ORDER_STATE_ACCEPT = 49;
  //部分成交
  static const int ORDER_STATE_PARTFINISHED = 50;
  //完全成交
  static const int ORDER_STATE_FINISHED = 51;
  //部分撤单
  static const int ORDER_STATE_PARTCANCELED = 52;
  //完全撤单
  static const int ORDER_STATE_CANCELED = 53;
  //已到期
  static const int ORDER_STATE_DELETEDFOREXPIRE = 54;
  //已挂起;
  static const int ORDER_STATE_SUPPENDED = 55;
  // 已撤余单
  static const int DY_ORDER_STATE_LEFTDELETED = 56;
  // 系统上报
  static const int DY_ORDER_STATE_SUBMIT = 57;
  // 策略待触发
  static const int DY_ORDER_STATE_TRIGGERING = 65;
  // 交易所待触
  static const int DY_ORDER_STATE_EXCTRIGGERING = 66;
  // 已排队
  static const int DY_ORDER_STATE_QUEUED = 67;
  // 待撤消
  static const int DY_ORDER_STATE_CANCELING = 68;
  // 待修改
  static const int DY_ORDER_STATE_MODIFYING = 69;
  // 策略删除
  static const int DY_ORDER_STATE_DELETED = 70;
  // 已生效——询价成功
  static const int DY_ORDER_STATE_EFFECT = 71;
  // 已申请——行权、弃权、套利等申请成功
  static const int DY_ORDER_STATE_APPLY = 72;
  // 用户提交
  static const int DY_ORDER_STATE_USER_SUBMIT = 73;

  /**
   * 获取订单状态
   * @param os
   * @return
   */
  static String getOrderState(int? os) {
    String state = "";
    switch (os) {
      case ORDER_STATE_FAIL:
        state = "交易失败";
        break;

      case ORDER_STATE_ACCEPT:
        state = "订单处理中";
        break;

      case ORDER_STATE_SUPPENDED:
        state = "已挂起";
        break;

      case ORDER_STATE_PARTFINISHED:
        state = "部分成交";
        break;

      case ORDER_STATE_FINISHED:
        state = "完全成交";
        break;

      case ORDER_STATE_CANCELED:
        state = "完全撤单";
        break;

      case ORDER_STATE_DELETEDFOREXPIRE:
        state = "已到期";
        break;

      case ORDER_STATE_PARTCANCELED:
        state = "部分撤单";
        break;

      case DY_ORDER_STATE_LEFTDELETED:
        state = "已撤余单";
        break;

      case DY_ORDER_STATE_SUBMIT:
        state = "系统上报";
        break;

      case DY_ORDER_STATE_TRIGGERING:
        state = "策略待触发";
        break;

      case DY_ORDER_STATE_EXCTRIGGERING:
        state = "交易所待触发";
        break;

      case DY_ORDER_STATE_QUEUED:
        state = "已排队";
        break;

      case DY_ORDER_STATE_CANCELING:
        state = "待撤消";
        break;

      case DY_ORDER_STATE_MODIFYING:
        state = "待修改";
        break;

      case DY_ORDER_STATE_DELETED:
        state = "策略删除";
        break;

      case DY_ORDER_STATE_EFFECT:
        state = "已生效——询价成功";
        break;

      case DY_ORDER_STATE_APPLY:
        state = "已申请";
        break;

      case DY_ORDER_STATE_USER_SUBMIT:
        state = "用户提交";
        break;
    }

    return state;
  }
}
