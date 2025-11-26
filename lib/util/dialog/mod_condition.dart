import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import '../../model/condition/condition.dart';
import '../../util/widget/number_box.dart';

import '../../config/common.dart';

class ModConditionDialog {
  List openTypeList = ["开仓", "平仓", "反手"]; //内盘+平今仓
  String openType = "开仓";
  List winLossTypeList = ["限价止损+限价止盈", "动态追踪", "限价止损", "限价止盈", "指定止损/止盈触发价"]; //内盘+平今仓
  String winLossType = "限价止损+限价止盈";
  List conditionTypeList = ["大于等于", "小于等于"];
  String conditionType = "大于等于";
  List orderTypeList = ["买入", "卖出"];
  String orderType = "买入";
  List timeLimitList = ["永久有效", "当日有效"];
  String timeLimit = "永久有效";
  int conditionNum = 1;
  int orderNum = 1;
  double lossMargin = 0;
  double winMargin = 0;

  Widget modDialog(BuildContext context, Condition? condition) {
    return ContentDialog(
        style: ContentDialogThemeData(
          decoration: BoxDecoration(
            color: Common.tradeButtonColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(15),
        ),
        constraints: const BoxConstraints(
          maxWidth: 630,
          maxHeight: 509,
        ),
        content: StatefulBuilder(builder: (_, setState) {
          return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(FluentIcons.cancel))
              ],
            ),
            Text(
              "修改云条件单",
              style: TextStyle(color: Common.contentDarkBgColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Common.contentLightBgColor,
                  border: Border.all(color: Common.dialogContentBorderBgColor),
                  borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.only(top: 10, bottom: 15),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      titleWidget("合约"),
                      Text(
                        condition?.ContractName ?? "--",
                        style: TextStyle(color: Common.contentDarkBgColor),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      titleWidget("条件"),
                      textWidget("价格"),
                      Container(
                        width: 100,
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ComboBox<String>(
                          value: conditionType,
                          isExpanded: true,
                          items: conditionTypeList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => conditionType = v!),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        width: 100,
                        child: NumberBox(
                          decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                          highlightColor: Colors.transparent,
                          unfocusedColor: Colors.transparent,
                          value: conditionNum,
                          min: 1,
                          clearButton: false,
                          onChanged: (v) => setState(() => conditionNum = v ?? 1),
                        ),
                      ),
                      Text(
                        "   手",
                        style: TextStyle(color: Common.commandTextColor),
                      )
                    ],
                  ).marginSymmetric(vertical: 10),
                  Row(
                    children: [
                      titleWidget("订单"),
                      SizedBox(
                        width: 100,
                        height: 36,
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
                      Container(
                        width: 100,
                        height: 36,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ComboBox<String>(
                          value: openType,
                          isExpanded: true,
                          items: openTypeList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => openType = v!),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                        width: 100,
                        child: NumberBox(
                          decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                          highlightColor: Colors.transparent,
                          unfocusedColor: Colors.transparent,
                          value: orderNum,
                          min: 1,
                          clearButton: false,
                          onChanged: (v) => setState(() => orderNum = v ?? 1),
                        ),
                      ),
                      Text(
                        "   手",
                        style: TextStyle(color: Common.commandTextColor),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      titleWidget("时效"),
                      SizedBox(
                        width: 100,
                        height: 36,
                        child: ComboBox<String>(
                          value: timeLimit,
                          isExpanded: true,
                          items: timeLimitList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => timeLimit = v!),
                        ),
                      ),
                    ],
                  ).marginSymmetric(vertical: 10),
                  Row(
                    children: [
                      titleWidget("损盈"),
                      SizedBox(
                        width: 186,
                        height: 36,
                        child: ComboBox<String>(
                          value: winLossType,
                          isExpanded: true,
                          items: winLossTypeList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => winLossType = v!),
                        ),
                      ),
                    ],
                  ).marginOnly(bottom: 10),
                  Container(
                    margin: const EdgeInsets.only(left: 60),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Common.containerBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Common.dialogContentBorderBgColor)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        textWidget(winLossType == "限价止损+限价止盈"
                            ? "止损价差"
                            : winLossType == "动态追踪"
                                ? "回撤差价"
                                : winLossType == "限价止损"
                                    ? "止损差价"
                                    : winLossType == "限价止盈"
                                        ? "止盈差价"
                                        : winLossType == "指定止损/止盈触发价"
                                            ? "止损触发价"
                                            : ""),
                        Container(
                          width: 100,
                          height: 36,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: NumberBox(
                            decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                            highlightColor: Colors.transparent,
                            unfocusedColor: Colors.transparent,
                            value: lossMargin,
                            min: 0,
                            clearButton: false,
                            onChanged: (v) => setState(() => lossMargin = v ?? 1),
                          ),
                        ),
                        if (winLossType == "限价止损+限价止盈" || winLossType == "指定止损/止盈触发价") textWidget(winLossType == "限价止损+限价止盈" ? "止盈价差" : "止盈触发价"),
                        if (winLossType == "限价止损+限价止盈" || winLossType == "指定止损/止盈触发价")
                          Container(
                            height: 36,
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: NumberBox(
                              decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                              highlightColor: Colors.transparent,
                              unfocusedColor: Colors.transparent,
                              value: winMargin,
                              min: 0,
                              clearButton: false,
                              onChanged: (v) => setState(() => winMargin = v ?? 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('取消', style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500)),
                ).marginOnly(right: 15),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  onPressed: () async {
                    Get.back();
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ).marginOnly(top: 20)
          ]);
        }));
  }

  Widget titleWidget(String text) {
    return SizedBox(
      width: 60,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }

  Widget unitText(String text) {
    return Text(
      text,
      style: TextStyle(color: Common.commandTextColor),
    );
  }

  Widget textWidget(String text) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Common.lightBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      width: 100,
      height: 36,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }
}
