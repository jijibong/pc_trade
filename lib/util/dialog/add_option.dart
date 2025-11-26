import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:trade/model/quote/contract.dart';
import 'package:trade/util/info_bar/info_bar.dart';

import '../../config/common.dart';
import '../../model/option/sector.dart';
import '../../page/quote/quote_logic.dart';
import '../event_bus/eventBus_utils.dart';
import '../event_bus/events.dart';
import '../shared_preferences/shared_preferences_key.dart';
import '../shared_preferences/shared_preferences_utils.dart';
import '../theme/theme.dart';
import '../utils/utils.dart';
import '../widget/dash_border.dart';

class AddOptionDialog {
  final ThemeController themeController = Get.find<ThemeController>();
  final QuoteLogic logic = Get.put(QuoteLogic());

  Widget addOptionDialog(Contract contract) {
    return ContentDialog(
      style: themeController.theme.dialogTheme,
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              "添加到自选",
              style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: themeController.theme.dialogTheme.barrierColor!,
                  strokeWidth: 0.72,
                  gap: 3,
                  dashWidth: 3,
                  borderRadius: 50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/icon_+@3x.png",
                      width: Common.iconImageWidth - 5,
                      color: themeController.theme.acrylicBackgroundColor,
                    ),
                    const Text(
                      "新建自选",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ).marginAll(5)
                  ],
                ),
              ),
              onTap: () {
                Get.dialog(addNewOption((e) async {
                  Sector newSector = Sector(name: e, type: 1, show: true, canDelete: true, editable: true, id: Utils.generateLenString(10));
                  logic.sectorList.add(newSector);
                  Map<Sector, List<Contract>> newMap = {};
                  for (var i in logic.sectorList) {
                    bool exist = false;
                    for (var e in logic.sectorMap.keys) {
                      if (i.id == e.id) {
                        exist = true;
                        newMap.addAll({i: logic.sectorMap[e] ?? []});
                      }
                    }
                    if (!exist) {
                      newMap.addAll({i: []});
                    }
                  }
                  logic.sectorMap.clear();
                  logic.sectorMap.addAll(newMap);
                  logic.showSectorMap.clear();
                  // logic.sectorList.clear();
                  for (var i in logic.sectorMap.keys) {
                    if (i.show == true) {
                      logic.showSectorMap.addAll({i: logic.sectorMap[i] ?? []});
                    }
                    // if (i.editable == true) {
                    //   logic.sectorList.add(i);
                    // }
                  }
                  final serialized = logic.serializeSectorMap(logic.sectorMap);
                  await SpUtils.set(SpKey.sector, serialized);
                }));
              },
            ).paddingSymmetric(horizontal: 15, vertical: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Common.dialogContentBorderBgColor),
              ),
              child: Obx(
                () => Scrollbar(
                    style: themeController.theme.scrollbarTheme,
                    child: ListView.builder(
                      itemCount: logic.sectorList.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(() => RadioButton(
                                  checked: logic.sector.value == logic.sectorList[index],
                                  onChanged: (checked) {
                                    logic.sector.value = logic.sectorList[index];
                                  },
                                )).marginAll(10),
                            AutoSizeText(logic.sectorList[index].name ?? ""),
                          ],
                        ).marginOnly(left: 10);
                      },
                    )),
              ),
            ).paddingSymmetric(horizontal: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Common.dialogContentBorderBgColor, width: 0.72),
                      ))),
                  child: Text(
                    "取消",
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Common.dialogContentBorderBgColor, width: 0.72),
                      ))),
                  child: Text(
                    "确认",
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (logic.sector.value.name == null) {
                      InfoBarUtils.showWarningBar("请选择自选板块");
                      return;
                    }
                    EventBusUtil.getInstance().fire(AddOptionEvent(logic.sector.value, contract, true));
                    Get.back();
                  },
                ),
              ],
            ).marginSymmetric(vertical: 20)
          ],
        ),
      ),
    );
  }

  Widget addNewOption(Function(String text) fun) {
    TextEditingController controller = TextEditingController();
    return ContentDialog(
      style: themeController.theme.dialogTheme,
      content: SizedBox(
        width: 230,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              "请输入自选名称",
              style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextBox(
              controller: controller,
              placeholder: "最多输入6个字",
              maxLines: 1,
              maxLength: 6,
            ).paddingSymmetric(horizontal: 15, vertical: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.contentLightBgColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Common.dialogContentBorderBgColor, width: 0.72),
                      ))),
                  child: Text(
                    "取消",
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 10)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(color: Common.dialogContentBorderBgColor, width: 0.72),
                      ))),
                  child: Text(
                    "确认",
                    style: TextStyle(color: Common.contentDarkBgColor, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    fun(controller.text);
                    Get.back();
                  },
                ),
              ],
            ).marginSymmetric(vertical: 20)
          ],
        ),
      ),
    );
  }

  Widget editDialog(List<Sector> sectorList, Function(List<Sector> sectorList) fun) {
    return ContentDialog(
      style: themeController.theme.dialogTheme,
      constraints: const BoxConstraints(
        maxWidth: 370,
        maxHeight: 270,
      ),
      content: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    Get.back();
                    fun(sectorList);
                  },
                  icon: const Icon(FluentIcons.cancel))
            ],
          ),
          Text(
            "编辑自选",
            style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Common.dialogContentBorderBgColor),
                  ),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: StatefulBuilder(
                    builder: (_, state) {
                      return Scrollbar(
                        key: UniqueKey(),
                        style: themeController.theme.scrollbarTheme,
                        child: ListView.builder(
                          itemCount: sectorList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              child: Row(
                                children: [
                                  Text(sectorList[index].name ?? "").marginOnly(left: 10),
                                  const Spacer(),
                                  IconButton(
                                          icon: Image.asset("assets/images/icon_edit2@3x.png", width: 17),
                                          onPressed: () {
                                            // if (index != 0) {
                                            //   var temp = sectorList[index];
                                            //   sectorList[index] = sectorList[index - 1];
                                            //   sectorList[index - 1] = temp;
                                            //   state(() {});
                                            // }
                                          })
                                      .marginSymmetric(horizontal: 10),
                                  IconButton(
                                      icon: Image.asset("assets/images/icon_up@3x.png", width: 17),
                                      onPressed: () {
                                        if (index != 0) {
                                          var temp = sectorList[index];
                                          sectorList[index] = sectorList[index - 1];
                                          sectorList[index - 1] = temp;
                                          state(() {});
                                        }
                                      }).marginSymmetric(horizontal: 10),
                                  IconButton(
                                      icon: Image.asset("assets/images/icon_down@3x.png", width: 17),
                                      onPressed: () {
                                        if (index != sectorList.length - 1) {
                                          var temp = sectorList[index];
                                          sectorList[index] = sectorList[index + 1];
                                          sectorList[index + 1] = temp;
                                          state(() {});
                                        }
                                      }).marginSymmetric(horizontal: 10),
                                  IconButton(
                                      icon: Image.asset("assets/images/icon_close@3x.png", width: 18),
                                      onPressed: () {
                                        sectorList.removeAt(index);
                                        state(() {});
                                      }).marginOnly(right: 20),
                                ],
                              ).paddingSymmetric(vertical: 2),
                            );
                          },
                        ),
                      );
                    },
                  )).paddingSymmetric(horizontal: 15)),
        ],
      ),
    );
  }
}
