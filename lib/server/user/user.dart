import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/trade/fund.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/log/log.dart';

class UserServer {
  ///获取资金账户信息
  static Future<ResFund?> getAccountFound() async {
    try {
      String? data;
      if (Common.signData) {
        var map = {"Currency": ""};
        data = await SignData().signData(jsonEncode(map), Config.getAccountFund);
      }
      Response response = await HttpUtils.getInstance().post(Config.getAccountFund, data: data);
      // logger.i(response);
      if (response.data["code"] == 0 ) {
        List list = response.data["data"];
        for (var element in list) {
          ResFund resFund = ResFund.fromJson(element);
          if (resFund.Currency == "JB") {
            return resFund;
          }
        }
      } else {
        logger.e("获取资金账户信息Failed：$response");
        // ToastUtil.showWarningToast(response.data["data"]);
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
