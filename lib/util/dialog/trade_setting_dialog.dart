import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart';

import '../../config/common.dart';
import '../shared_preferences/shared_preferences_key.dart';
import '../shared_preferences/shared_preferences_utils.dart';
import '../../util/widget/number_box.dart';

class TradeSettingDialog {
  bool defaultTradeType = true;
  int defaultTradeMenu = 0; //默认下单面板

  Widget tradeSetting() {
    return ContentDialog(
        style: ContentDialogThemeData(
            padding: const EdgeInsets.all(5),
            bodyPadding: EdgeInsets.zero,
            decoration: BoxDecoration(color: Common.contentLightBgColor, borderRadius: BorderRadius.circular(20))),
        constraints: const BoxConstraints(
          maxWidth: 488,
          maxHeight: 500,
        ),
        content: StatefulBuilder(builder: (_, setState) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Image.asset(
                        "assets/images/icon_close@3x.png",
                        width: 22,
                      ))
                ],
              ),
              Text(
                "交易设置",
                style: TextStyle(color: Common.contentDarkBgColor, fontSize: 18, fontWeight: FontWeight.bold),
              ).marginOnly(bottom: 15),
              settingTypeItem("默认下单方式", defaultTradeMenu, yes: "快捷", no: "三键", or: "传统"),
              settingItem("是否提示下单确认", true),
              settingItem("是否默认进入自选", true),
              settingItem("是否显示精简模式", true),
              settingItem("是否弹出交易弹窗", true),
              settingItem("默认下单类型", defaultTradeType, yes: "限价", no: "市价", onChange: (v) async {
                defaultTradeType = true;
                await SpUtils.set(SpKey.defaultTradeType, defaultTradeType);
                setState(() {});
              }, onChanged: (v) async {
                defaultTradeType = false;
                await SpUtils.set(SpKey.defaultTradeType, defaultTradeType);
                setState(() {});
              }),
              settingItem("成交提示音", yes: "开启", no: "关闭", true),
              settingNumberItem("默认下单手数"),
            ],
          );
        }));
  }

  Widget settingItem(String title, bool checked, {String? yes, String? no, String? or, Function(bool)? onChange, Function(bool)? onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(color: Common.commandTextColor, fontSize: 14),
              )),
          Expanded(
              flex: 2,
              child: RadioButton(
                  style: radioButtonThemeData(),
                  checked: checked,
                  content: Text(
                    yes ?? "是",
                    style: TextStyle(fontSize: 14, color: Common.contentDarkBgColor),
                  ),
                  onChanged: onChange)),
          Expanded(
              flex: 2,
              child: RadioButton(
                  style: radioButtonThemeData(),
                  checked: !checked,
                  content: Text(
                    no ?? "否",
                    style: TextStyle(fontSize: 14, color: Common.contentDarkBgColor),
                  ),
                  onChanged: onChanged)),
          const Spacer(flex: 2)
        ],
      ),
    );
  }

  Widget settingTypeItem(String title, int index, {String? yes, String? no, String? or}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(color: Common.commandTextColor, fontSize: 14),
              )),
          Expanded(
              flex: 2,
              child: RadioButton(
                  checked: index == 0,
                  content: Text(yes ?? "是", style: TextStyle(fontSize: 14, color: Common.contentDarkBgColor)),
                  onChanged: (v) async {
                    defaultTradeMenu = 0;
                  })),
          Expanded(
              flex: 2,
              child: RadioButton(
                  checked: index == 1,
                  content: Text(no ?? "否", style: TextStyle(fontSize: 14, color: Common.contentDarkBgColor)),
                  onChanged: (v) async {
                    defaultTradeMenu = 1;
                  })),
          Expanded(
              flex: 2,
              child: RadioButton(
                  checked: index == 2,
                  content: Text(or ?? "或", style: TextStyle(fontSize: 14, color: Common.contentDarkBgColor)),
                  onChanged: (v) async {
                    defaultTradeMenu = 2;
                  })),
        ],
      ),
    );
  }

  Widget settingNumberItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(color: Common.commandTextColor, fontSize: 14),
              )),
          Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(color: Common.tradeTypeButtonColor, borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      child: Text(
                        "1",
                        style: TextStyle(color: Common.contentDarkBgColor),
                        textAlign: TextAlign.center,
                      ).marginSymmetric(vertical: 5),
                      onTap: () async {
                        await SpUtils.set(SpKey.defaultTradeNumber, 1);
                      },
                    )),
                    Container(
                      width: 3,
                      height: 36,
                      color: Common.dialogLightBgColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Text(
                          "2",
                          style: TextStyle(color: Common.contentDarkBgColor),
                          textAlign: TextAlign.center,
                        ).marginSymmetric(vertical: 5),
                        onTap: () async {
                          await SpUtils.set(SpKey.defaultTradeNumber, 2);
                        },
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 36,
                      color: Common.dialogLightBgColor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        child: Text(
                          "3",
                          style: TextStyle(color: Common.contentDarkBgColor),
                          textAlign: TextAlign.center,
                        ).marginSymmetric(vertical: 5),
                        onTap: () async {
                          await SpUtils.set(SpKey.defaultTradeNumber, 3);
                        },
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(width: 10),
          Expanded(
              flex: 2,
              child: SizedBox(
                height: 36,
                child: NumberBox(
                    decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                    highlightColor: Colors.transparent,
                    unfocusedColor: Colors.transparent,
                    min: 0,
                    value: 1,
                    clearButton: false,
                    onChanged: (v) async {
                      await SpUtils.set(SpKey.defaultTradeNumber, v);
                    }),
              )),
          IconButton(
            icon: Image.asset(
              "assets/images/icon_fuwei@3x.png",
              width: 16,
            ),
            onPressed: () {},
          ).marginOnly(right: 10),
        ],
      ),
    );
  }

  RadioButtonThemeData radioButtonThemeData() {
    return RadioButtonThemeData(
      checkedDecoration: WidgetStateProperty.resolveWith((states) {
        return BoxDecoration(
          border: Border.all(
            color: Common.selectedRadioButtonColor,
            width: !states.isDisabled
                ? states.isHovered && !states.isPressed
                    ? 4.4
                    : 6.0
                : 5.0,
          ),
          shape: BoxShape.circle,
        );
      }),
    );
  }
}
