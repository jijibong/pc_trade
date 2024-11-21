import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:web_socket_client/web_socket_client.dart';

import '../../config/config.dart';
import '../../model/broker/quote_address.dart';
import '../../model/delegation/res_comm_order.dart';
import '../../model/delegation/res_del_order.dart';
import '../../model/pb/trade/cmd.pb.dart';
import '../../model/pb/trade/proto.pb.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/time_in_force_type.dart';
import '../../model/quote/trade_operation.dart';
import '../../model/socket_packet/operation.dart';
import '../../model/trade/fund.dart';
import '../../model/trade/res_float_profit.dart';
import '../../model/trade/res_hold_order.dart';
import '../../model/user/user.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/event_bus/events.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../login/login.dart';
import '../trade/deal.dart';

class TradeWebSocketServer {
  WebSocket? socket;
  late StreamSubscription quoteDataSubscription;
  final String floatPosSub = "floatPosSub";
  final String floatTotalSub = "floatTotalSub";

  void initSocket(String? url) async {
    const backoff = ConstantBackoff(Duration(seconds: 10));
    socket = WebSocket(Uri.parse('ws://$url:${Config.TradePort}/'), timeout: const Duration(seconds: 10), backoff: backoff, binaryType: 'arraybuffer');
    socket?.messages.listen((message) {
      onReceivedMsg(message);
    });
    socket?.connection.listen((state) {
      if ((state == const Connected() || state == const Reconnected()) && UserUtils.currentUser != null && UserUtils.currentUser!.token != null) {
        CDFYReqUserAuthField authReq = CDFYReqUserAuthField(token: UserUtils.currentUser!.token);
        cmd c = cmd(option: Option.REQ_OPT_AUTH, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: authReq.writeToBuffer());
        socket?.send(c.writeToBuffer());
      } else {
        logger.f("trade state:$state");
      }
    });
  }

  /// 接收到socket消息
  onReceivedMsg(List<int> event) async {
    cmd c = cmd.fromBuffer(event);
    // logger.f(c);
    switch (c.option) {
      case Option.REQ_OPT_AUTH:
        CDFYRspUserAuthField subResp = CDFYRspUserAuthField.fromBuffer(c.data);
        if (subResp.code == 0) {
          try {
            SubscribeSubPartPrivateReq subPartPrivateResp = SubscribeSubPartPrivateReq();
            cmd cm = cmd(
                option: Option.REQ_SUBSCRIBE_SUB_PART_PRIVATE,
                reqId: Int64(1),
                dateTime: Int64(DateTime.now().microsecondsSinceEpoch),
                data: subPartPrivateResp.writeToBuffer());
            socket?.send(cm.writeToBuffer());

            /// 浮盈相关
            // if (mSubMap.containsKey(floatPosSub)) {
            //   SSubscribeSubPartPrivateResp subPartPrivateResp = SSubscribeSubPartPrivateResp();
            // cmd cm = cmd(
            //     option: mSubMap[floatPosSub],
            //     reqId: Int64(1),
            //     dateTime: Int64(DateTime.now().microsecondsSinceEpoch),
            //     data: subPartPrivateResp.writeToBuffer());
            // socket.send(cm.writeToBuffer());
            // }
            // if (mSubMap.containsKey(floatPosSub)) {
            //   SSubscribeSubPartPrivateResp subPartPrivateResp = SSubscribeSubPartPrivateResp();
            // cmd cm = cmd(
            //     option: mSubMap[floatPosSub],
            //     reqId: Int64(1),
            //     dateTime: Int64(DateTime.now().microsecondsSinceEpoch),
            //     data: subPartPrivateResp.writeToBuffer());
            // socket.send(cm.writeToBuffer());
            // }
          } catch (e) {
            logger.e("认证反馈解析异常");
          }
        } else {
          // logger.e("交易链接认证失败;${subResp.code}:${subResp.msg}");
          // InfoBarUtils.showErrorDialog("交易链接认证失败;${subResp.code}:${subResp.msg}");
          dispose();
          // LoginServer.isLogin = false;
          // UserUtils.currentUser = null;
          // SpUtils.remove(SpKey.currentUser);
          // Get.to(() => const Home());
        }
        break;
      case Option.REQ_SUBSCRIBE_SUB_PART_PRIVATE: // 订阅系统部分私有数据
        SSubscribeSubPartPrivateResp subResp = SSubscribeSubPartPrivateResp.fromBuffer(c.data);
        // logger.i("订阅系统部分私有数据: $subResp");
        break;
      case Option.REQ_SUBSCRIBE_SUB_ALL_PRIVATE: // 订阅系统所有私有数据
        ReqSubscribeSubAllPrivateReq subResp = ReqSubscribeSubAllPrivateReq.fromBuffer(c.data);
        logger.i("订阅系统所有私有数据: $subResp");
        break;
      case Option.REQ_SUBSCRIBE_SUB_POSITION_FLOAT: // 订阅持仓浮盈通知
        ReqSubscribeSubPrivateFloatResp subResp = ReqSubscribeSubPrivateFloatResp.fromBuffer(c.data);
        logger.i("订阅持仓浮盈通知: $subResp");
        break;
      case Option.REQ_UN_SUBSCRIBE_SUB_POSITION_FLOAT: // 取消订阅持仓浮盈通知
        ReqUnsubscribeFloatResp subResp = ReqUnsubscribeFloatResp.fromBuffer(c.data);
        logger.i("取消订阅持仓浮盈通知: $subResp");
        break;
      case Option.REQ_UN_SUBSCRIBE_SUB_ALL_PRIVATE: // 取消订阅所有私有数据
        ReqUnsubscribeAllResp subResp = ReqUnsubscribeAllResp.fromBuffer(c.data);
        logger.i("取消订阅所有私有数据: $subResp");
        break;
      case Option.REQ_SUBSCRIBE_SUB_FUND: // 订阅资金信息通知
        ReqSubscribeFundResp subResp = ReqSubscribeFundResp.fromBuffer(c.data);
        logger.i("订阅资金信息通知: $subResp");
        break;
      case Option.REQ_UN_SUBSCRIBE_SUB_FUND: // 取消订阅资金信息通知
        ReqUnsubscribeFundResp subResp = ReqUnsubscribeFundResp.fromBuffer(c.data);
        logger.i("取消订阅资金信息通知: $subResp");
        break;
      case Option.ON_ACCOUNT_FORCE_CLOSE: // 风控强平用户持仓通知
        CDFYRspOnAccountForceClose subResp = CDFYRspOnAccountForceClose.fromBuffer(c.data);
        logger.i("风控强平用户持仓通知: $subResp");
        break;
      case Option.ON_ACCOUNT_RISK_WARNING: // 警告信息信息通知
        CDFYRspOnAccountRiskWarning subResp = CDFYRspOnAccountRiskWarning.fromBuffer(c.data);
        logger.i("警告信息信息通知: $subResp");
        break;
      case Option.ON_ACCOUNT_FUND_UPDATE: // 用户资金变化通知
        try {
          CDFYRspOnAccountFund raf = CDFYRspOnAccountFund.fromBuffer(c.data);
          // logger.i("用户资金变化通知: $raf");
          ResFund resFund = ResFund(
            Cname: raf.fund.currency,
            Currency: raf.fund.currency,
            PreEquity: raf.fund.preEquity,
            FrozenDeposit: raf.fund.frozenDeposit,
            Fee: raf.fund.fee,
            OccupyDeposit: raf.fund.occupyDeposit,
            TermInitial: raf.fund.termInitial,
            CashInValue: raf.fund.cashInValue,
            CashOutValue: raf.fund.cashOutValue,
            CloseProfit: raf.fund.closeProfit,
            Equity: raf.fund.equity,
            Available: raf.fund.available,
            FloatProfit: raf.fund.floatProfit,
          );
          EventBusUtil.getInstance().fire(FundUpdateEvent(res: resFund));
        } catch (e) {
          Log.e("资金变化解析异常：$e");
        }
        break;
      case Option.ON_ACCOUNT_ORDER_UPDATE: // 委托变化通知
        try {
          CDFYRspOrderDetail rod = CDFYRspOrderDetail.fromBuffer(c.data);
          logger.i("委托变化通知: $rod");
          ResDelOrder dele = ResDelOrder(
            CommodityNo: rod.commodityNo,
            CommodityType: rod.commodityType,
            CommodityTickSize: rod.commodityTickSize,
            ContractName: rod.contractName,
            ContractNo: rod.contractNo,
            CreateTime: rod.createTime,
            ErrorCode: rod.errorCode,
            ErrorText: rod.errorText,
            ExchangeNo: rod.exchangeNo,
            ExpireTime: rod.expireTime,
            OrderId: rod.orderId,
            TradeCurrency: rod.tradeCurrency,
            OrderPrice: rod.orderPrice,
            OrderQty: rod.orderQty,
            MatchQty: rod.matchQty,
            OrderSide: rod.orderSide,
            OrderState: rod.orderState,
            OrderType: rod.orderType,
            PositionEffect: rod.positionEffect,
            StopPrice: rod.stopPrice,
            TimeInForce: rod.timeInForce,
            OrderOpType: rod.orderOpType,
          );
          EventBusUtil.getInstance().fire(DelRecordEvent(res: dele));
        } catch (e) {
          logger.e("订单状态改变解析异异常：$e");
        }
        break;
      case Option.ON_ACCOUNT_FILL_UPDATE: // 成交变化通知
        try {
          CDFYRspFillDetail rspFillDetail = CDFYRspFillDetail.fromBuffer(c.data);
          logger.i("成交变化通知: $rspFillDetail");
          checkNeedBackHand(rspFillDetail);
          ResComOrder rco = ResComOrder(
            CommodityNo: rspFillDetail.commodityNo,
            CommodityType: rspFillDetail.commodityType,
            ContractName: rspFillDetail.contractName,
            ContractNo: rspFillDetail.contractNo,
            FeeCurrency: rspFillDetail.feeCurrency,
            FeeValue: rspFillDetail.feeValue,
            MatchNo: rspFillDetail.matchNo,
            MatchPrice: rspFillDetail.matchPrice,
            MatchSide: rspFillDetail.matchSide,
            MatchTime: rspFillDetail.createTime,
            OrderId: rspFillDetail.orderId,
            PositionEffect: rspFillDetail.positionEffect,
            CommodityTickSize: rspFillDetail.commodityTickSize,
          );
          EventBusUtil.getInstance().fire(FillUpdateEvent(res: rco));
        } catch (e) {
          logger.e("订单成交通知解析异常：$e");
        }
        break;
      case Option.ON_ACCOUNT_POSITION_UPDATE: // 持仓变化通知
        try {
          CDFYRspPositionDetail rph = CDFYRspPositionDetail.fromBuffer(c.data);
          logger.i("持仓变化通知: $rph");
          ResHoldOrder rho = ResHoldOrder(
            CommodityNo: rph.commodityNo,
            CommodityType: rph.commodityType,
            ContractName: rph.contractName,
            ContractNo: rph.contractNo,
            ContractCode: "${rph.commodityNo}${rph.contractNo}",
            ExchangeNo: rph.exchangeNo,
            MatchSide: rph.side,
            PositionPrice: rph.positionPrice,
            PositionProfit: rph.positionFloat,
            PositionQty: rph.positionQty,
            TradeCurrency: rph.tradeCurrency,
            PositionNo: rph.positionNo,
            CreateTime: rph.createTime,
            TradeTime: rph.createTime,
            ContractSize: rph.contractSize,
            MarginValue: rph.deposit,
            CommodityTickSize: rph.commodityTickSize,
          );
          EventBusUtil.getInstance().fire(PositionUpdateEvent(res: rho));
        } catch (e) {
          logger.e("持仓改变解析异常:$e");
        }
        break;
      case Option.ON_ACCOUNT_POSITION_FLOAT: // 持仓浮盈通知
        try {
          CDFYRspOnAccountPositionFloat rph = CDFYRspOnAccountPositionFloat.fromBuffer(c.data);
          // logger.i("持仓浮盈通知: $rph");
          ResFloatProfit pl = ResFloatProfit(
            CalculatePrice: rph.calculatePrice,
            PositionNo: rph.positionNo,
            PositionProfit: rph.positionProfit,
            UpdateTime: rph.updateTime,
          );
          EventBusUtil.getInstance().fire(PositionFloatEvent(res: pl));
        } catch (e) {
          logger.e("持仓盈亏解析异常：$e");
        }
        break;
      case Option.ON_ACCOUNT_RATE_UPDATE: // 汇率变化通知
        break;
      case Option.ON_ACCOUNT_FORCE_EXIT: // 强制退出消息通知
        LoginOutResp subResp = LoginOutResp.fromBuffer(c.data);
        logger.i("强制退出消息通知: $subResp");
        // if (subResp.code == 2) {
        // LoginServer.isLogin = false;
        // UserUtils.currentUser = null;
        // SpUtils.remove(SpKey.currentUser);
        // HttpUtils();
        // TradeWebSocketServer().dispose();
        // EventBusUtil.getInstance().fire(SubEvent([], Operation.RevLoginOut));
        // Get.offAll(Home(msg: subResp.msg));
        // }
        break;
      default:
        logger.e("Unknown binary message received");
        break;
    }
  }

  /// 检测是否需要反手开仓
  void checkNeedBackHand(CDFYRspFillDetail fill) async {
    String? operation = await SpUtils.getString(fill.orderLocalID);
    if (operation == TradeOperation.BackHand) {
      // 需要反手开仓
      String ExchangeNo = fill.exchangeNo;
      String CommodityNo = fill.commodityNo;
      String ContractNo = fill.contractNo;
      int CommodityType = fill.commodityType;
      int OrderType = Order_Type.ORDER_TYPE_MARKET;
      int TimeInForce = TimeInForceType.ORDER_TIMEINFORCE_GFD;
      String ExpireTime = "";
      int OrderSide = fill.matchSide;
      double OrderPrice = 0;
      double StopPrice = 0;
      int OrderQty = fill.matchQty;
      int PositionEffect = PositionEffectType.PositionEffect_OPEN;
      // String ClientOrderId = DeviceUtil.createLocalOrderId();

      await DealServer.addOrder(ExchangeNo, CommodityNo, ContractNo, CommodityType, OrderType, TimeInForce, ExpireTime, OrderSide, OrderPrice, StopPrice,
          OrderQty, PositionEffect, "");

      SpUtils.remove(fill.orderLocalID);
    }
  }

  void dispose() {
    socket?.close();
  }
}
