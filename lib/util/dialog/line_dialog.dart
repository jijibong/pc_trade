import 'package:fluent_ui/fluent_ui.dart' hide NumberBox, TimePicker, DatePicker;
import 'package:get/get.dart';
import '../../util/widget/number_box.dart';

import '../../config/common.dart';
import '../../model/k/custom_line.dart';
import '../theme/theme.dart';

class LineDialog {
  Widget showLineDialog(CustomLine customLine, String code, {void Function()? function}) {
    final appTheme = AppTheme();
    List typeList = ["买入", "卖出", "平仓"];
    String type = customLine.type == 1
        ? "买入"
        : customLine.type == 2
            ? "卖出"
            : "平仓";
    List priceTypeList = ["画线价", "对手价", "超价", "市价"];
    return ContentDialog(
      style: ContentDialogThemeData(
          padding: EdgeInsets.zero,
          bodyPadding: EdgeInsets.zero,
          decoration: BoxDecoration(color: appTheme.unColor, borderRadius: BorderRadius.zero)),
      content: Container(
          height: 240,
          color: Common.dialogContentColor,
          child: StatefulBuilder(builder: (_, state) {
            return Column(
              children: [
                Container(
                  color: Common.dialogTitleColor,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/jmaster.ico",
                        width: 20,
                      ),
                      Expanded(
                        child: Text(
                          "画线下单属性",
                          style: TextStyle(color: appTheme.color),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(FluentIcons.cancel))
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text("合约：$code"),
                  ],
                ).marginSymmetric(horizontal: 15, vertical: 5),
                Row(
                  children: [
                    const Text("条件：价格   "),
                    Expanded(
                        child: NumberBox(
                      value: customLine.kPrice,
                      onChanged: (v) => state(() => customLine.kPrice = v),
                      smallChange: 0.01,
                      clearButton: false,
                    )),
                  ],
                ).marginSymmetric(horizontal: 15, vertical: 5),
                Row(
                  children: [
                    const Text("订单："),
                    Expanded(
                      child: ComboBox<String>(
                        value: type,
                        isExpanded: true,
                        items: typeList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() {
                          type = v ?? "买入";
                          if (v == "买入") {
                            customLine.type = 1;
                          } else if (v == "卖出") {
                            customLine.type = 2;
                          } else if (v == "平仓") {
                            customLine.type = 3;
                          }
                        }),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                        child: NumberBox(
                      value: customLine.num,
                      min: 1,
                      onChanged: (v) => state(() => customLine.num = v),
                    )),
                    const Text(" 手 "),
                    Expanded(
                      child: ComboBox<String>(
                        value: customLine.price,
                        isExpanded: true,
                        items: priceTypeList.map((e) {
                          return ComboBoxItem<String>(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) => state(() => customLine.price = v),
                      ),
                    ),
                  ],
                ).marginSymmetric(horizontal: 15, vertical: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "确认",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Get.back();
                        if (function != null) function();
                      },
                    ),
                    Button(
                      style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "取消",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                ).marginSymmetric(vertical: 15)
              ],
            );
          })),
    );
  }
}
