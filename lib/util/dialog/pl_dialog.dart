import 'package:fluent_ui/fluent_ui.dart' hide NumberBox, TimePicker, DatePicker;
import 'package:get/get.dart';

import '../../config/common.dart';
import '../theme/theme.dart';

class PLDialog {
  Widget showPLDialog(String price, String win, {void Function()? functionConfirm, void Function()? functionCancel}) {
    final appTheme = AppTheme();
    return ContentDialog(
      style: ContentDialogThemeData(
          padding: EdgeInsets.zero,
          bodyPadding: EdgeInsets.zero,
          decoration: BoxDecoration(color: appTheme.unColor, borderRadius: BorderRadius.zero)),
      content: Container(
          height: 180,
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
                          "修改止盈止损价格",
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
                Text(
                  "修改止$win价格为：$price",
                  style: TextStyle(color: appTheme.color),
                ).marginSymmetric(vertical: 25),
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
                        if (functionConfirm != null) functionConfirm();
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
                        if (functionCancel != null) functionCancel();
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
