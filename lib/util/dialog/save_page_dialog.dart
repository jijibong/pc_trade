import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../config/common.dart';
import '../../model/option/myPage.dart';
import '../../model/option/sector.dart';
import '../../page/quote/quote_logic.dart';
import '../info_bar/info_bar.dart';
import '../theme/theme.dart';

class SavePageDialog {
  final ThemeController themeController = Get.find<ThemeController>();
  final QuoteLogic logic = Get.put(QuoteLogic());
  TextEditingController textEditingController = TextEditingController();

  Widget savePage(List<MyPage> pages, Function(String name) fun) {
    MyPage? myPage;
    return ContentDialog(
      style: themeController.theme.dialogTheme,
      constraints: const BoxConstraints(
        maxWidth: 370,
        maxHeight: 395,
      ),
      content: Column(
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
            "保存当前页面",
            style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextBox(
            controller: textEditingController,
            placeholder: "请输入页面名称",
            placeholderStyle: TextStyle(color: Common.commandTextColor),
            decoration: WidgetStatePropertyAll(BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(8),
            )),
          ).paddingSymmetric(horizontal: 15, vertical: 20),
          Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Common.dialogContentBorderBgColor),
              ),
              child: StatefulBuilder(
                builder: (_, state) {
                  return Scrollbar(
                      key: UniqueKey(),
                      style: themeController.theme.scrollbarTheme,
                      child: ListView.builder(
                        itemCount: pages.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RadioButton(
                                checked: myPage == pages[index],
                                onChanged: (checked) {
                                  if (checked) {
                                    myPage = pages[index];
                                  } else {
                                    myPage = null;
                                  }
                                  state(() {});
                                },
                              ).marginAll(10),
                              AutoSizeText(pages[index].name ?? ""),
                            ],
                          ).marginOnly(left: 10);
                        },
                      ));
                },
              )).paddingSymmetric(horizontal: 15),
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
                  if (textEditingController.text.isEmpty) {
                    InfoBarUtils.showWarningDialog("名称不能为空，保存失败！");
                    return;
                  }
                  if (pages.isNotEmpty) {
                    for (var i in pages) {
                      if (i.name == textEditingController.text) {
                        InfoBarUtils.showWarningDialog("名称重复，保存失败！");
                        return;
                      }
                    }
                  }
                  fun(textEditingController.text);
                  Get.back();
                },
              ),
            ],
          ).marginSymmetric(vertical: 20)
        ],
      ),
    );
  }
}
