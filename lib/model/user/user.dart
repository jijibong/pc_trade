import 'package:fluent_ui/fluent_ui.dart';

import '../quote/rate.dart';

class UserUtils {
  static User? currentUser;
  static BuildContext? appContext;
}

class User {
  String? nick;
  int? id;
  int? status;
  String? account;
  String? remark;
  String? token;
  List<Rate>? rates;

  User({this.nick, this.id, this.status, this.account, this.remark, this.token, this.rates});

  User.fromJson(Map<String, dynamic> json) {
    nick = json['Nick'];
    id = json['Id'];
    status = json['Status'];
    account = json['Account'];
    token = json['Token'];
    remark = json['Remark'];
    if (json['Rates'] != null) rates = (json['Rates'] as List).map((e) => Rate.fromJson(e)).toList();
  }
}
