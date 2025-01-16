import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/condition/condition.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/user/user.dart';
import '../../server/condition/condition.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/widget/number_box.dart';

class ConditionPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const ConditionPage({super.key, required this.params});

  @override
  State<ConditionPage> createState() => _ConditionPageState();
}

class _ConditionPageState extends State<ConditionPage> with MultiWindowListener {
  double boxWidth = 108;
  double boxHeight = 34;
  double padWidth = 12;
  double price = 0.00;
  double wtPrice = 0.00;
  int wtVol = 1;
  List priceList = ["最新价", "买价", "卖价"];
  List priceTypeList = [">=", "<="];
  String priceType = ">=";
  List orderTypeList = ["市价", "限价"];
  String orderType = "市价";
  List validList = ["当日有效", "永久有效"];
  String valid = "当日有效";
  String fragTriggerPriceTypeText = "最新价";
  String fragPriceConditionText = ">=";
  List bsList = ["买入", "卖出"];
  List ocList = ["开仓", "平仓"];
  String fragBsText = "买入";
  String fragOcText = "开仓";
  int mTriggerPriceType = 1, mOrderSide = SideType.SIDE_SELL, mPositionEffect = PositionEffectType.PositionEffect_COVER;
  Condition selectedCondition = Condition();
  List<Condition> mConditionList = [];
  late AppTheme appTheme;
  ScrollController scrollController = ScrollController();

  int windowId() {
    return widget.params["windowId"];
  }

  void startDragging(bool isMainWindow) {
    if (isMainWindow) {
      windowManager.startDragging();
    } else {
      WindowController.fromWindowId(kWindowId!).startDragging();
    }
  }

  void setMovable(bool isMainWindow, bool movable) {
    if (isMainWindow) {
      windowManager.setMovable(movable);
    } else {
      WindowController.fromWindowId(kWindowId!).setMovable(movable);
    }
  }

  initData() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventNewCondition) {
        windowOnTop(windowId());
      }
    });

    String? baseUrl = await SpUtils.getString(SpKey.baseUrl);
    String? userInfo = await SpUtils.getString(SpKey.currentUser);
    if (baseUrl != null && userInfo != null) {
      Config.URL = baseUrl;
      UserUtils.currentUser = User.fromJson(jsonDecode(userInfo));
      HttpUtils();
      qryCondition(1);
    } else {
      InfoBarUtils.showErrorBar("获取交易地址失败，请重新登录！");
    }
  }

  void qryCondition(int status) async {
    await ConditionServer.queryTodayCondition().then((value) {
      if (value != null) {
        mConditionList.clear();
        for (Condition con in value) {
          if (status != 0) {
            if (con.Status == status) {
              mConditionList.add(con);
            }
          } else {
            mConditionList.add(con);
          }
        }
        mConditionList.sort((lhs, rhs) {
          if (lhs.UpdateStamp == null) {
            return 1;
          }
          if (rhs.UpdateStamp == null) {
            return -1;
          }
          if (lhs.UpdateStamp == rhs.UpdateStamp) {
            return 0;
          } else {
            return lhs.UpdateStamp! > rhs.UpdateStamp! ? -1 : 1;
          }
        });

        if (mounted) setState(() {});
      }
    });
  }

  ///修改条件单
  void reqUpdateCondition() async {
    if (selectedCondition.Id != null) {
      int priceType = 1, mTimeInForce = 1, conditionType = 1, mOrderSide = SideType.SIDE_SELL, mPositionEffect = PositionEffectType.PositionEffect_COVER;
      int mOrderPriceType = Order_Type.ORDER_TYPE_MARKET;
      if (orderType == "限价") {
        priceType = 2;
        mOrderPriceType = Order_Type.ORDER_TYPE_LIMIT;
      }
      if (valid == "永久有效") {
        mTimeInForce = 2;
      }
      if (fragBsText == "买入") {
        mOrderSide = SideType.SIDE_BUY;
      }
      if (fragOcText == "开") {
        mPositionEffect = PositionEffectType.PositionEffect_OPEN;
      }
      if (fragPriceConditionText == ">=") {
        conditionType = 2;
      }
      await ConditionServer.updateCondition(
              selectedCondition.Id, mOrderPriceType, mTimeInForce, "", mOrderSide, wtPrice, wtVol, mPositionEffect, priceType, conditionType, price)
          .then((value) {
        if (value) qryCondition(1);
      });
    } else {
      InfoBarUtils.showErrorBar("请选择要修改的条件单");
    }
  }

  void refreshCondition() {
    if (selectedCondition.Id != null) {
      mTriggerPriceType = selectedCondition.PriceType ?? 1;
      switch (selectedCondition.PriceType) {
        case 1: //最新价
          fragTriggerPriceTypeText = "最新价";
          break;
        case 2: //买价
          fragTriggerPriceTypeText = "买价";
          break;
        case 3: //卖价
          fragTriggerPriceTypeText = "卖价";
          break;
      }
      switch (selectedCondition.ConditionType) {
        case 1:
          fragPriceConditionText = ">=";
          break;
        case 2:
          fragPriceConditionText = "<=";
          break;
      }
      price = selectedCondition.ConditionPrice ?? 0.0;
      mOrderSide = selectedCondition.OrderSide ?? SideType.SIDE_SELL;
      wtPrice = selectedCondition.OrderPrice ?? 0.0;
      wtVol = selectedCondition.OrderQty ?? 1;
      if (mOrderSide == SideType.SIDE_BUY) {
        fragBsText = "买入";
      } else if (mOrderSide == SideType.SIDE_SELL) {
        fragBsText = "卖出";
      }
      mPositionEffect = selectedCondition.PositionEffect ?? PositionEffectType.PositionEffect_COVER;
      switch (mPositionEffect) {
        case PositionEffectType.PositionEffect_OPEN:
          fragOcText = "开仓";
          break;
        case PositionEffectType.PositionEffect_COVER:
          fragOcText = "平仓";
          break;
      }
      valid = selectedCondition.TimeInForce == 1 ? "当日有效" : "永久有效";
      if (selectedCondition.PriceType == 1) {
        orderType = "市价";
      } else {
        orderType = "限价";
      }
      if (mounted) setState(() {});
    } else {
      price = 0.00;
      wtPrice = 0.00;
      wtVol = 1;
      priceType = ">=";
      orderType = "市价";
      valid = "当日有效";
      fragTriggerPriceTypeText = "最新价";
      fragPriceConditionText = ">=";
      fragBsText = "买入";
      fragOcText = "开仓";
    }
  }

  @override
  void onWindowClose() async {
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
      // await rustDeskWinManager.call(WindowType.Main, kWindowEventHide, {"id": kWindowId!});
    }

    // hide window on close
    final controller = WindowController.fromWindowId(kWindowId!);
    await notMainWindowClose(controller);
    super.onWindowClose();
  }

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.addListener(this);
    initData();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return NavigationView(
      appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          height: 30,
          backgroundColor: appTheme.commandBarColor,
          title: GestureDetector(
            onPanStart: (_) => startDragging(false),
            onPanCancel: () {
              if (isMacOS) {
                setMovable(false, false);
              }
            },
            onPanEnd: (_) {
              if (isMacOS) {
                setMovable(false, false);
              }
            },
            child: Row(children: [
              Image.asset('assets/images/jmaster.ico', width: 16, height: 16),
              Expanded(
                  child: const Text(
                "条件单修改",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ).marginOnly(left: 2))
            ]).marginOnly(
              left: 2,
              right: 2,
            ),
          ),
          actions: IconButton(
              icon: const Icon(
                FluentIcons.chrome_close,
                color: Colors.white,
              ),
              onPressed: () {
                // WindowController.fromWindowId(windowId()).hide();
                Future.delayed(Duration.zero, () async {
                  await WindowController.fromWindowId(kWindowId!).close();
                });
              })),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Common.conditionTopBgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("触发条件设置"),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("合约   ${selectedCondition.ContractName ?? ""}   ${selectedCondition.ContractNo ?? ""}"),
                    ),
                    Row(
                      children: [
                        const Text("价格"),
                        Container(
                          height: boxHeight,
                          width: boxWidth,
                          margin: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                          child: ComboBox<String>(
                            value: fragTriggerPriceTypeText,
                            isExpanded: true,
                            items: priceList.map((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => fragTriggerPriceTypeText = v!),
                          ),
                        ),
                        Container(
                          height: boxHeight,
                          width: boxWidth * 0.8,
                          margin: EdgeInsets.fromLTRB(padWidth, 8, 0, 8),
                          child: ComboBox<String>(
                            value: fragPriceConditionText,
                            isExpanded: true,
                            items: priceTypeList.map((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => fragPriceConditionText = v!),
                          ),
                        ),
                        Container(
                          height: boxHeight,
                          width: boxWidth * 0.8,
                          margin: EdgeInsets.fromLTRB(padWidth, 8, 0, 8),
                          child: NumberBox(
                            value: price,
                            smallChange: 0.01,
                            min: 0.00,
                            onChanged: (v) {
                              price = v!;
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text("触发后下单设置"),
                    ),
                    Row(
                      children: [
                        const Text("订单类型"),
                        Container(
                          height: boxHeight,
                          width: boxWidth,
                          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: ComboBox<String>(
                            value: orderType,
                            isExpanded: true,
                            items: orderTypeList.map((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => orderType = v!),
                          ),
                        ),
                        const Text("委托价格"),
                        Container(
                          height: boxHeight,
                          width: boxWidth * 0.8,
                          margin: EdgeInsets.fromLTRB(padWidth / 2, 8, 8, 8),
                          child: NumberBox(
                            value: wtPrice,
                            min: 0.00,
                            smallChange: 0.01,
                            onChanged: (v) {},
                          ),
                        ),
                        const Text("委托数量"),
                        Container(
                          height: boxHeight,
                          width: boxWidth * 0.8,
                          margin: EdgeInsets.fromLTRB(padWidth / 2, 8, 8, 8),
                          child: NumberBox(
                            value: wtVol,
                            min: 0,
                            onChanged: (v) {},
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("买卖方向"),
                        Container(
                          height: boxHeight,
                          width: boxWidth,
                          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: ComboBox<String>(
                            value: fragBsText,
                            isExpanded: true,
                            items: bsList.map((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => fragBsText = v!),
                          ),
                        ),
                        const Text("开平方向"),
                        Container(
                          height: boxHeight,
                          width: boxWidth * 0.8,
                          margin: EdgeInsets.fromLTRB(padWidth / 2, 8, 8, 8),
                          child: ComboBox<String>(
                            value: fragOcText,
                            isExpanded: true,
                            items: ocList.map((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => fragOcText = v!),
                          ),
                        ),
                        const Text("有效日期"),
                        Container(
                          height: boxHeight,
                          width: boxWidth,
                          margin: EdgeInsets.fromLTRB(padWidth / 2, 8, 8, 8),
                          child: ComboBox<String>(
                            value: valid,
                            isExpanded: true,
                            items: validList.map((e) {
                              return ComboBoxItem<String>(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => valid = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(flex: 3, child: Container()),
                        Button(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                              shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                          child: const Text(
                            "修改",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            reqUpdateCondition();
                          },
                        ),
                        Container(
                          width: 20,
                        ),
                        Button(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                              shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                          child: const Text(
                            "复位",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            refreshCondition();
                          },
                        ),
                        Expanded(flex: 2, child: Container()),
                      ],
                    )
                  ],
                ),
              )),
          Expanded(
              flex: 5,
              child: Container(
                color: Common.conditionBottomBgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text("  已设置的条件单列表")),
                    Flexible(
                      child: Container(
                          constraints: const BoxConstraints(minHeight: 120),
                          child: Scrollbar(
                            key: UniqueKey(),
                            controller: scrollController,
                            style: const ScrollbarThemeData(thickness: 10, padding: EdgeInsets.zero, hoveringPadding: EdgeInsets.zero),
                            child: SingleChildScrollView(
                                controller: scrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: mConditionList.length + 1,
                                        itemBuilder: (BuildContext context, int index) {
                                          if (index == 0) {
                                            return Row(
                                              children: [
                                                Expanded(flex: 2, child: tableTitleItem("条件单编号")),
                                                Expanded(flex: 1, child: tableTitleItem("状态")),
                                                Expanded(flex: 3, child: tableTitleItem("条件")),
                                                Expanded(flex: 3, child: tableTitleItem("触发下单")),
                                              ],
                                            );
                                          } else {
                                            String priceType = "";
                                            switch (mConditionList[index - 1].PriceType) {
                                              case 1:
                                                priceType = "最新价";
                                                break;
                                              case 2:
                                                priceType = "买价";
                                                break;
                                              case 3:
                                                priceType = "卖价";
                                                break;
                                            }
                                            String constr = "${mConditionList[index - 1].CommodityNo}${mConditionList[index - 1].ContractNo}";
                                            switch (mConditionList[index - 1].ConditionType) {
                                              case 1:
                                                constr = "$constr $priceType>=${mConditionList[index - 1].ConditionPrice}";
                                                break;
                                              case 2:
                                                constr = "$constr $priceType<=${mConditionList[index - 1].ConditionPrice}";
                                                break;
                                            }
                                            String status = "";
                                            switch (mConditionList[index - 1].Status) {
                                              case 1:
                                                status = "未触发";
                                                break;
                                              case 2:
                                                status = "已删除";
                                                break;
                                              case 3:
                                                status = "到期删除";
                                                break;
                                              case 4:
                                                status = "已触发";
                                                break;
                                              case 5:
                                                status = "指令失败";
                                                break;
                                            }
                                            return GestureDetector(
                                              child: Container(
                                                color: mConditionList[index - 1].selected ? Colors.black.withOpacity(0.2) : Colors.transparent,
                                                child: IntrinsicHeight(
                                                    child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    Expanded(flex: 2, child: tableTitleItem(mConditionList[index - 1].ConditionOrderNo)),
                                                    Expanded(flex: 1, child: tableTitleItem(status)),
                                                    Expanded(flex: 3, child: tableTitleItem(constr)),
                                                    Expanded(
                                                        flex: 3,
                                                        child: tableTitleItem(
                                                            "以市价${mConditionList[index - 1].OrderPrice ?? 0.00}${mConditionList[index - 1].OrderSide == SideType.SIDE_SELL ? "卖出" : "买入"}${mConditionList[index - 1].PositionEffect == PositionEffectType.PositionEffect_OPEN ? "开仓" : "平仓"}${mConditionList[index - 1].OrderQty}手")),
                                                  ],
                                                )),
                                              ),
                                              onTap: () {
                                                if (mConditionList[index - 1].selected == true) return;
                                                for (var element in mConditionList) {
                                                  element.selected = false;
                                                }
                                                mConditionList[index - 1].selected = true;
                                                selectedCondition = mConditionList[index - 1];
                                                refreshCondition();
                                                if (mounted) setState(() {});
                                              },
                                            );
                                          }
                                        }))),
                          )),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "  说明:1.条件单一旦设置就立刻生效，客户端关闭仍然会触发",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Text("  2.条件单修改后只会触发一次，如果触发时资金不够导致下单失败，后果由客户自己承担", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget tableTitleItem(String? text) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: appTheme.exchangeBgColor)),
      padding: const EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: AnimatedFluentTheme(
        data: FluentThemeData(),
        child: Tooltip(
            message: text ?? "--",
            style: const TooltipThemeData(preferBelow: true),
            child: Text(
              text ?? "--",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: appTheme.color),
            )),
      ),
    );
  }
}
