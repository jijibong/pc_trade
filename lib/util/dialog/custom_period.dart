import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart';
import 'package:trade/util/info_bar/info_bar.dart';
import '../../model/k/k_flag.dart';
import '../../model/k/k_preiod.dart';
import '../../util/widget/number_box.dart';

import '../../config/common.dart';
import '../theme/theme.dart';

class CustomPeriodDialog {
  final ThemeController themeController = Get.find<ThemeController>();
  List periodList = ["分钟", "小时", "日", "周", "月", "年"];
  String selectedPeriod = "分钟";
  int num = 1;

  Widget customPeriod(List<KPeriod> kPeriodList,Function(List<KPeriod> kPeriodList) fun) {
    return ContentDialog(
        style: themeController.theme.dialogTheme,
        constraints: const BoxConstraints(
          maxWidth: 370,
          maxHeight: 480,
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
                    icon: Image.asset(
                      "assets/images/icon_close@3x.png",
                      width: 22,
                    ))
              ],
            ),
            Text(
              "自定义分析周期",
              style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleWidget("已创建"),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: themeController.isDarkMode.value ? Common.checkBoxBorderDarkColor : Common.checkBoxBorderLightColor),
                        ),
                        width: 195,
                        height: 185,
                        child: ListView.builder(
                          itemCount: kPeriodList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              child: Row(
                                children: [
                                  Text(kPeriodList[index].name ?? "").marginOnly(left: 10),
                                  const Spacer(),
                                  IconButton(
                                      icon: Image.asset("assets/images/icon_up@3x.png", width: 17),
                                      onPressed: () {
                                        if (index != 0) {
                                          var temp = kPeriodList[index];
                                          kPeriodList[index] = kPeriodList[index - 1];
                                          kPeriodList[index - 1] = temp;
                                          setState(() {});
                                        }
                                      }),
                                  IconButton(
                                      icon: Image.asset("assets/images/icon_down@3x.png", width: 17),
                                      onPressed: () {
                                        if (index != kPeriodList.length - 1) {
                                          var temp = kPeriodList[index];
                                          kPeriodList[index] = kPeriodList[index + 1];
                                          kPeriodList[index + 1] = temp;
                                          setState(() {});
                                        }
                                      }),
                                  IconButton(
                                      icon: Image.asset("assets/images/icon_close@3x.png", width: 18),
                                      onPressed: () {
                                        kPeriodList.removeAt(index);
                                        setState(() {});
                                      }).marginOnly(right: 10),
                                ],
                              ).paddingSymmetric(vertical: 2),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      titleWidget("时间周期"),
                      SizedBox(
                        width: 195,
                        height: 36,
                        child: ComboBox<String>(
                          value: selectedPeriod,
                          isExpanded: true,
                          items: periodList.map((e) {
                            return ComboBoxItem<String>(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectedPeriod = v!),
                        ),
                      ),
                    ],
                  ).marginSymmetric(vertical: 10),
                  Row(
                    children: [
                      titleWidget("设置参数"),
                      SizedBox(
                        width: 195,
                        height: 36,
                        child: NumberBox(
                          decoration: WidgetStatePropertyAll(BoxDecoration(borderRadius: BorderRadius.circular(10))),
                          highlightColor: Colors.transparent,
                          unfocusedColor: Colors.transparent,
                          value: num,
                          min: 0,
                          clearButton: false,
                          onChanged: (v) => setState(() => num = v ?? 1),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Button(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(themeController.isDarkMode.value ? Common.collectIconDarkColor : Common.tradeTypeButtonColor),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), side: BorderSide(color: Common.dialogContentBorderBgColor)))),
                        onPressed: () {
                          var flag = KPFlag.Minute;
                          switch (selectedPeriod) {
                            case "分钟":
                              flag = KPFlag.Minute;
                              break;
                            case "小时":
                              flag = KPFlag.Hour;
                              break;
                            case "日":
                              flag = KPFlag.Day;
                              break;
                            case "周":
                              flag = KPFlag.Week;
                              break;
                            case "月":
                              flag = KPFlag.Month;
                              break;
                            case "年":
                              flag = KPFlag.Year;
                              break;
                          }
                          KPeriod newPeriod = KPeriod(name: "$num$selectedPeriod", period: num, cusType: 2, kpFlag: flag, periodType: selectedPeriod);
                          for (var per in kPeriodList) {
                            if (per.name == newPeriod.name) {
                              InfoBarUtils.showErrorBar("已存在相同的自定义周期");
                              return;
                            }
                          }
                          kPeriodList.add(newPeriod);
                          setState(() {});
                        },
                        child: Image.asset(
                          "assets/images/icon_collect_nor@3x.png",
                          width: 15,
                        ),
                      ).marginOnly(right: 15),
                      Button(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 30)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                        onPressed: () async {
                          fun(kPeriodList);
                          Get.back();
                        },
                        child: Text(
                          '确定',
                          style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ).marginOnly(top: 20)
                ],
              ),
            ),
          ]);
        }));
  }

  Widget titleWidget(String text) {
    return SizedBox(
      width: 80,
      child: Text(
        text,
        style: TextStyle(color: Common.commandTextColor),
      ),
    );
  }
}
