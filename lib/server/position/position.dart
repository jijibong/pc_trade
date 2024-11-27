import 'package:dio/dio.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/trade/res_hold_order.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';

class PositionServer {
  ///查询持仓
  static Future<List<ResHoldOrder>?> queryPosition() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.queryPosition);
      }
      Response response = await HttpUtils.getInstance().post(Config.queryPosition, data: data);
      // logger.i(response);
      if (response.data["code"] == 0) {
        List<ResHoldOrder> resHoldOrderList = [];
        List<dynamic> list = response.data["data"] ?? [];
        resHoldOrderList = list.map((e) => ResHoldOrder.fromJson(e)).toList();
        return resHoldOrderList;
      } else {
        return [];
      }
    } on DioException {
      rethrow;
    }
  }
}
