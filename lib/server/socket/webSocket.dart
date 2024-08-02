import 'dart:async';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:fixnum/fixnum.dart';
import '../../config/config.dart';
import 'package:web_socket_client/web_socket_client.dart';
import '../../model/broker/quote_address.dart';
import '../../model/k/k_time.dart';
import '../../model/pb/quote/body.pb.dart';
import '../../model/pb/quote/cmd.pb.dart';
import '../../model/pb/quote/fill.pb.dart';
import '../../model/pb/quote/kdata.pb.dart';
import '../../model/pb/quote/line.pbenum.dart';
import '../../model/pb/quote/quote.pb.dart';
import '../../model/quote/contract.dart';
import '../../model/socket_packet/operation.dart';
import '../../util/event_bus/eventBus_utils.dart';
import '../../util/event_bus/events.dart';
import '../../util/log/log.dart';
import '../../util/utils/market_util.dart';
import '../../util/utils/utils.dart';

class WebSocketServer {
  bool isAuth = false;
  static List<QuoteAddr> quoteAddress = [];
  WebSocket socket = WebSocket(Uri.parse(''));
  late StreamSubscription quoteDataSubscription;
  List? subJson;

  void initSocket() async {
    const backoff = ConstantBackoff(Duration(seconds: 10));
    socket = WebSocket(Uri.parse(Config.WebScoketUrl), timeout: const Duration(seconds: 10), backoff: backoff, binaryType: 'arraybuffer');

    socket.messages.listen((message) {
      onReceivedMsg(message);
    });

    socket.connection.listen((state) {
      logger.i(state);
      if (state == const Connected() || state == const Reconnected()) {
        AuthReq authReq = AuthReq(auth: Config.Token);
        cmd c = cmd(option: Option.OPT_Auth, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: authReq.writeToBuffer());
        socket.send(c.writeToBuffer());
      }
    });

    listenSubEvent();
  }

  /// 接收到socket消息
  onReceivedMsg(List<int> event) async {
    try {
      cmd c = cmd.fromBuffer(event);
      switch (c.option) {
        case Option.OPT_Auth:
          AuthResp authResp = AuthResp.fromBuffer(c.data);
          isAuth = true;
          logger.i("Auth Response: $authResp");
          break;
        case Option.OPT_Sub:
          SubResp subResp = SubResp.fromBuffer(c.data);
          logger.i("SubResp Response: $subResp");
          break;
        case Option.OPT_SubFill:
          SubFillResp subFillResp = SubFillResp.fromBuffer(c.data);
          logger.i("SubFillResp Response: $subFillResp");
          break;
        case Option.OPT_UnSubFill:
          UnSubFillResp unSubFillResp = UnSubFillResp.fromBuffer(c.data);
          logger.i("UnSubFillResp Response: $unSubFillResp");
          break;
        case Option.OPT_SubQuote:
          SubQuoteResp subQuoteResp = SubQuoteResp.fromBuffer(c.data);
          // logger.i("SubQuote Response: $subQuoteResp");
          break;
        case Option.OPT_UnSubQuote:
          UnSubQuoteResp unSubQuoteResp = UnSubQuoteResp.fromBuffer(c.data);
          // logger.i("UnSubQuote Response: $unSubQuoteResp");
          break;
        case Option.OPT_SubKline:
          SubKlineResp subKlineResp = SubKlineResp.fromBuffer(c.data);
          logger.i("SubKline Response: $subKlineResp");
          break;
        case Option.OPT_UnSubKline:
          UnSubKlineResp unSubKlineResp = UnSubKlineResp.fromBuffer(c.data);
          logger.i("UnSubKline Response: $unSubKlineResp");
          break;
        case Option.OPT_RtnQuote:
          GZipDecoder gzip = GZipDecoder();
          List<int> decodeBody = gzip.decodeBytes(c.data);
          parseQuotePb(decodeBody);
          break;
        case Option.OPT_RtnKline:
          // logger.i("K线周期变化通知");
          try {
            GZipDecoder gzip = GZipDecoder();
            List<int> decodeBody = gzip.decodeBytes(c.data);
            KlineData sk = KlineData.fromBuffer(decodeBody);
            // CorrKlineEvent corr = CorrKlineEvent(
            //     key: sk.key,
            //     data: DataBean(
            //       amount: sk.data.amount,
            //       close: sk.data.close,
            //       high: sk.data.high,
            //       low: sk.data.low,
            //       open: sk.data.open,
            //       uxTime: sk.data.uxTime.toInt(),
            //       volume: sk.data.volume,
            //     ));
            // EventBusUtil.getInstance().fire(corr);
          } catch (e) {
            logger.i("K线周期变化通知解析失败:$e");
          }
          break;
        case Option.OPT_RtnFill:
          try {
            GZipDecoder gzip = GZipDecoder();
            List<int> decodeBody = gzip.decodeBytes(c.data);
            FillData fill = FillData.fromBuffer(decodeBody);
            EventBusUtil.getInstance().fire(QuoteFilledData(fill));
            // logger.i("Option OPT_RtnFill：$fill");
          } catch (e) {
            logger.i("解析成交逐笔推送数据异常$e");
          }
          break;
        default:
          logger.e("Unknown binary message received");
          break;
      }
    } catch (e) {
      logger.e("webSocket消息解析失败:$e");
    }
  }

  ///解析行情
  void parseQuotePb(List<int> bytes) {
    // logger.i("解析行情");
    try {
      QuoteData response = QuoteData.fromBuffer(bytes);
      String excd = response.contract.commodity.exchangeNo;
      String comcode = response.contract.commodity.commodityNo;
      String scode1 = response.contract.contractNo1;
      int comType = ascii.encode(response.contract.commodity.commodityType).single;
      scode1 = scode1.length > 4 ? scode1.substring(scode1.length - 4, scode1.length) : scode1;
      Contract? contract = MarketUtils.getVariety(excd, comcode + scode1, comType);
      if (contract == null) return;
      if (response.contract.callOrPutFlag1 != "") contract.changeFlag = response.contract.callOrPutFlag1;
      if (response.currencyNo != "") contract.currency = response.currencyNo;
      if (response.tradingState != "") contract.tradeState = response.tradingState;
      if (response.dateTimeStamp != "") {
        contract.timeStr = response.dateTimeStamp;
        contract.timeStamps = (num.parse(Utils.getLongTime(response.dateTimeStamp)));
      }
      if (response.qPreClosingPrice != 0) contract.prePrice = response.qPreClosingPrice;
      if (response.qPreSettlePrice != 0) contract.preSettlePrice = response.qPreSettlePrice;

      contract.prePosition = response.qPrePositionQty;
      contract.openPrice = response.qOpeningPrice;
      contract.lastPrice = response.qLastPrice;
      contract.highPrice = response.qHighPrice;
      contract.lowPrice = response.qLowPrice;
      contract.hisHigh = response.qHisHighPrice;
      contract.hisLow = response.qHisLowPrice;
      contract.limitPrice = response.qLimitUpPrice;
      contract.stopPrice = response.qLimitDownPrice;
      contract.volume = response.qTotalQty;
      contract.turnOver = response.qTotalTurnover;
      contract.position = response.qPositionQty;
      contract.averPrice = response.qAveragePrice;
      contract.settlePrice = response.qSettlePrice;
      contract.lastVolume = response.qLastQty;
      contract.implieBuy = response.qImpliedBidPrice;
      contract.implieBuyNum = response.qImpliedBidQty.toInt();
      contract.implieSale = response.qImpliedAskPrice;
      contract.implieSaleNum = response.qImpliedAskQty.toInt();
      contract.preVirtuality = response.qPreDelta;
      contract.virtuality = response.qCurrDelta;
      contract.in_vouume = response.qInsideQty;
      contract.out_vouume = response.qOutsideQty;
      contract.turn_rate = response.qTurnoverRate;
      contract.five_aver = response.q5DAvgQty;
      contract.pe_rate = response.qPERatio;
      contract.all_marketValue = response.qTotalValue;
      contract.cir_marketValue = response.qNegotiableValue;
      contract.positionTrend = response.qPositionTrend.toString();
      contract.rise_speed = response.qChangeSpeed;
      contract.changePer = response.qChangeRate;
      contract.change = response.qChangeValue;
      contract.amplitude = response.qSwing;
      contract.delegateBuy = response.qTotalBidQty;
      contract.delegateSale = response.qTotalAskQty;

      for (var element in response.appleBuy) {
        Level2 level = Level2();
        level.price = element.price;
        level.volume = element.volume;
        contract.setLevel2(level, response.appleBuy.indexOf(element));
        if (response.appleBuy.indexOf(element) == 0) {
          contract.buyPrice = element.price;
        }
      }

      for (var element in response.appleSell) {
        Level2 level = Level2();
        level.price = element.price;
        level.volume = element.volume;
        contract.setLevel2(level, response.appleSell.indexOf(element) + 20);
        if (response.appleSell.indexOf(element) == 0) {
          contract.salePrice = element.price;
        }
      }

      MarketUtils.updateVariety(contract);
      EventBusUtil.getInstance().fire(QuoteEvent(contract));
    } catch (e) {
      // try {
      //   FillData fill = FillData.fromBuffer(bytes);
      //   logger.i("成交逐笔推送：$fill");
      // } catch (error) {
      //   logger.e("成交逐笔解析异常:$e");
        // logger.e("成交逐笔解析异常:$e,$error");
      // }
    }
  }

  listenSubEvent() {
    quoteDataSubscription = EventBusUtil.getInstance().on<SubEvent>().listen((event) {
      int option = event.option;
      switch (option) {
        case Operation.SendSub:
          if (isAuth) {
            for (var element in event.json) {
              SubQuoteReq subQuoteReq = SubQuoteReq(key: element.trim());
              cmd cm =
                  cmd(option: Option.OPT_SubQuote, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: subQuoteReq.writeToBuffer());
              socket.send(cm.writeToBuffer());
            }
          }
          break;
        case Operation.UnSendSub:
          if (isAuth) {
            for (var element in event.json) {
              UnSubQuoteReq unSubQuoteReq = UnSubQuoteReq(key: element.trim());
              cmd cm = cmd(
                  option: Option.OPT_UnSubQuote, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: unSubQuoteReq.writeToBuffer());
              socket.send(cm.writeToBuffer());
            }
          }
          break;
        case Operation.SendSubFillData:
          for (var element in event.json) {
            logger.i("成交逐笔：$element");
            SubFillReq subFillReq = SubFillReq(key: element.trim());
            cmd cm = cmd(option: Option.OPT_SubFill, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: subFillReq.writeToBuffer());
            socket.send(cm.writeToBuffer());
          }
          break;
        case Operation.SendUnSubFillData:
          for (var element in event.json) {
            logger.i("取消订阅成交逐笔：$element");
            UnSubFillReq unSubFillReq = UnSubFillReq(key: element.trim());
            cmd cm =
                cmd(option: Option.OPT_UnSubFill, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: unSubFillReq.writeToBuffer());
            socket.send(cm.writeToBuffer());
          }
          break;
        case Operation.RecvSubKlineData:
          // logger.i("订阅k线");
          Line? line;
          switch (event.period) {
            case KTime.H_1:
              line = Line.KL1H;
              break;
            case KTime.M_1:
              line = Line.KL1M;
              break;
            case KTime.M_3:
              line = Line.KL3M;
              break;
            case KTime.M_5:
              line = Line.KL5M;
              break;
            case KTime.M_10:
              line = Line.KL10M;
              break;
            case KTime.M_15:
              line = Line.KL15M;
              break;
            case KTime.M_30:
              line = Line.KL30M;
              break;
            case KTime.DAY:
              line = Line.KL1D;
              break;
            default:
              line = Line.KL1M;
              break;
          }
          SubKlineReq subKlineReq = SubKlineReq(key: event.json.first, line: line);
          cmd cm = cmd(option: Option.OPT_SubKline, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: subKlineReq.writeToBuffer());
          socket.send(cm.writeToBuffer());
          break;
        case Operation.RecvUnSubKlineData:
          logger.i("取消订阅k线");
          Line? line;
          switch (event.period) {
            case KTime.H_1:
              line = Line.KL1H;
              break;
            case KTime.M_1:
              line = Line.KL1M;
              break;
            case KTime.M_3:
              line = Line.KL3M;
              break;
            case KTime.M_5:
              line = Line.KL5M;
              break;
            case KTime.M_10:
              line = Line.KL10M;
              break;
            case KTime.M_15:
              line = Line.KL15M;
              break;
            case KTime.M_30:
              line = Line.KL30M;
              break;
            case KTime.DAY:
              line = Line.KL1D;
              break;
            default:
              line = Line.KL1M;
              break;
          }
          UnSubKlineReq subKlineReq = UnSubKlineReq(key: event.json.first, line: line);
          cmd cm =
              cmd(option: Option.OPT_UnSubKline, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: subKlineReq.writeToBuffer());
          socket.send(cm.writeToBuffer());
          break;
        case Operation.RevLoginOut:
          UnSubAllReq unSubAllReq = UnSubAllReq();
          cmd cm = cmd(option: Option.OPT_UnSubAll, reqId: Int64(1), dateTime: Int64(DateTime.now().microsecondsSinceEpoch), data: unSubAllReq.writeToBuffer());
          socket.send(cm.writeToBuffer());
          break;
      }
    });
  }

  void dispose() {
    isAuth = false;
    socket.close();
  }
}
