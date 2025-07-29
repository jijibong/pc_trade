import 'package:trade/model/option/sector.dart';

import '../k/k_preiod.dart';
import '../quote/contract.dart';

class MyPage {
  String? name;
  int? multiScreen; //分屏下当前屏幕序号
  int? selectedIndex; //分屏下当前屏幕序号
  List<int>? viewIndexList; //首页\详情页
  List<int>? showChartList; //图表\列表
  List<Contract>? contractList; //当前合约
  List<KPeriod>? kPeriodList; //周期
  List<Sector>? selectedSector; //板块

  MyPage({
    this.name,
    this.multiScreen,
    this.selectedIndex,
    this.viewIndexList,
    this.showChartList,
    this.contractList,
    this.kPeriodList,
    this.selectedSector,
  });

  MyPage.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    multiScreen = json['multiScreen'];
    selectedIndex = json['selectedIndex'];
    viewIndexList = json['viewIndexList'] != null ? List<int>.from(json['viewIndexList']) : null;
    showChartList = json['showChartList'] != null ? List<int>.from(json['showChartList']) : null;
    contractList = (json['contractList'] as List?)?.map((e) => Contract.fromJson(e)).toList() ?? [];
    kPeriodList = (json['kPeriodList'] as List?)?.map((e) => KPeriod.fromJson(e)).toList() ?? [];
    selectedSector = (json['selectedSector'] as List?)?.map((e) => Sector.fromJson(e)).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'multiScreen': multiScreen,
      'selectedIndex': selectedIndex,
      'viewIndexList': viewIndexList,
      'showChartList': showChartList,
      'contractList': contractList?.map((e) => e.toJson()).toList(),
      'kPeriodList': kPeriodList?.map((e) => e.toJson()).toList(),
      'selectedSector': selectedSector?.map((e) => e.toJson()).toList(),
    };
  }
}
