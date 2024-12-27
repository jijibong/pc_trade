import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/broker/broker.dart';
import '../../model/user/user.dart';
import '../../util/http/http.dart';
import '../../util/http/sign_data.dart';
import '../../util/http/update_http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/log/log.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';

class LoginServer {
  static bool isLogin = false;

  ///查询ip
  static Future<IpAddress?> requestNetIp() async {
    try {
      Response response = await UpHttpUtils.getInstance().post(Config.queryIpAddress, data: {"BrokerId": ""});
      // logger.w(response);
      if (response.data["code"] == 0) {
        IpAddress ipAddress = IpAddress.fromJson(response.data["data"]);
        return ipAddress;
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///查询服务商
  static Future<Broker?> queryBroker(String brokerId) async {
    try {
      Response response = await UpHttpUtils.getInstance()
          .post(Config.queryBroker, data: {"BrokerId": brokerId, "PlatAttr": Common.platAttr, "EnvironmentalType": Common.environment});
      logger.w(response);
      if (response.data["code"] == 0) {
        Broker broker = Broker.fromJson(response.data["data"]);
        return broker;
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///获取验证码
  static Future<String?> getVCode() async {
    try {
      String? data;
      if (Common.signData) {
        data = await SignData().signData("", Config.vcodeIdUrl);
      }
      Response response = await HttpUtils.getInstance().post(Config.vcodeIdUrl, data: data);
      // logger.w(response);
      if (response.data["code"] == 0) {
        String vCode = response.data["data"];
        return vCode;
      } else if (response.data['msg'] != null) {
        InfoBarUtils.showErrorBar(response.data['msg']);
      } else {
        InfoBarUtils.showErrorBar("查询验证码失败");
      }
    } on DioException {
      rethrow;
    }
    return null;
  }

  ///登录
  static Future<dynamic> login(String account, String pwd, String brokerId, String? mac, String? ip) async {
    ///元泓：230101/123123  FCS：A230712/123123  NP230511
    try {
      Response response = await HttpUtils.getInstance().post(Config.loginUrl,
          data: {"Account": account, "Password": pwd, "BrokerId": brokerId, "Platform": Common.desktopPlatform, "Site": "达渊", "Mac": mac, "Ip": ip});
      logger.w(response);
      if (response.data["code"] == 0) {
        UserUtils.currentUser = User.fromJson(response.data["data"]);
        SpUtils.set(SpKey.currentUser, jsonEncode(response.data["data"]));
        LoginServer.isLogin = true;
        return true;
      } else if (response.data['msg'] != null) {
        return response.data['msg'];
      } else {
        return "登录失败";
      }
    } on DioException {
      rethrow;
    }
  }
}
