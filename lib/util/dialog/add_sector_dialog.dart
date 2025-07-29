import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../config/common.dart';
import '../info_bar/info_bar.dart';
import '../theme/theme.dart';

class AddSectorDialog {
  Widget addSectorDialog(Function(String text) fun) {
    final appTheme = AppTheme();
    TextEditingController controller = TextEditingController(text: "");
    return ContentDialog(
      style: ContentDialogThemeData(
          padding: EdgeInsets.zero,
          bodyPadding: EdgeInsets.zero,
          decoration: BoxDecoration(color: appTheme.unColor, borderRadius: BorderRadius.zero)),
      content: Container(
        height: 200,
        color: Common.dialogContentColor,
        child: Column(
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
                      "新建板块",
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
            const Row(
              children: [
                Text("请输入板块名称:"),
              ],
            ).marginSymmetric(horizontal: 15),
            Row(
              children: [
                Expanded(child: TextBox(controller: controller)),
              ],
            ).marginAll(15),
            const Spacer(),
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
                    if (controller.text.isEmpty) {
                      InfoBarUtils.showWarningBar("板块名称不能为空");
                      return;
                    }
                    Get.back();
                    fun(controller.text);
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
            ).marginOnly(bottom: 20)
          ],
        ),
      ),
    );
  }
}
