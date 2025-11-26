import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../config/common.dart';
import '../../model/user/user.dart';
import '../theme/theme.dart';

class InfoBarUtils {
  static bool _isDialogVisible = false;
  static final ThemeController themeController = Get.find<ThemeController>();

  static showWarningBar(String text) async {
    if (UserUtils.appContext != null) {
      await displayInfoBar(UserUtils.appContext!, alignment: Alignment.center, builder: (context, close) {
        return InfoBar(
          title: Text(text),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.warning,
        );
      });
    }
  }

  static showSuccessBar(String text) async {
    if (UserUtils.appContext != null) {
      await displayInfoBar(UserUtils.appContext!, builder: (context, close) {
        return InfoBar(
          title: Text(text),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.success,
        );
      });
    }
  }

  static showErrorBar(String text) async {
    if (UserUtils.appContext != null) {
      await displayInfoBar(UserUtils.appContext!, builder: (context, close) {
        return InfoBar(
          title: Text(text),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.error,
        );
      });
    }
  }

  static showInfoBar(String text) async {
    if (UserUtils.appContext != null) {
      await displayInfoBar(UserUtils.appContext!, builder: (context, close) {
        return InfoBar(
          title: Text(text),
          action: IconButton(
            icon: const Icon(FluentIcons.clear),
            onPressed: close,
          ),
          severity: InfoBarSeverity.info,
        );
      });
    }
  }

  static showWarningDialog(String text) async {
    if (UserUtils.appContext != null) {
      if (!_isDialogVisible) {
        _isDialogVisible = true;
        Get.dialog(ContentDialog(
          style: themeController.theme.dialogTheme,
          content: Container(
            height: 180,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          _isDialogVisible = false;
                          Get.back();
                        },
                        icon: Icon(FluentIcons.cancel, color: themeController.theme.acrylicBackgroundColor))
                  ],
                ).marginOnly(bottom: 15),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.warning,
                            size: 36,
                            color: Colors.yellow,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Text(
                            text,
                            style: TextStyle(color: themeController.theme.acrylicBackgroundColor),
                          )),
                        ],
                      )),
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6, horizontal: 28)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  child: const Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _isDialogVisible = false;
                    Get.back();
                  },
                ).marginOnly(bottom: 15),
              ],
            ),
          ),
        ));
      }
    } else {
      InfoBarUtils.showWarningBar(text);
    }
  }

  static showSuccessDialog(String text) async {
    if (UserUtils.appContext != null) {
      if (!_isDialogVisible) {
        _isDialogVisible = true;
        Get.dialog(ContentDialog(
          style: themeController.theme.dialogTheme,
          content: Container(
            height: 180,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          _isDialogVisible = false;
                          Get.back();
                        },
                        icon: Icon(FluentIcons.cancel, color: themeController.theme.acrylicBackgroundColor))
                  ],
                ).marginOnly(bottom: 15),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.accept,
                            size: 36,
                            color: Colors.green,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Text(
                            text,
                            style: TextStyle(color: themeController.theme.acrylicBackgroundColor),
                          )),
                        ],
                      )),
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6, horizontal: 28)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  child: const Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _isDialogVisible = false;
                    Get.back();
                  },
                ).marginOnly(bottom: 15),
              ],
            ),
          ),
        ));
      }
    } else {
      InfoBarUtils.showSuccessBar(text);
    }
  }

  static showErrorDialog(String text) async {
    if (UserUtils.appContext != null) {
      if (!_isDialogVisible) {
        _isDialogVisible = true;
        Get.dialog(ContentDialog(
          style: themeController.theme.dialogTheme,
          content: Container(
            height: 180,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          _isDialogVisible = false;
                          Get.back();
                        },
                        icon: Icon(FluentIcons.cancel, color: themeController.theme.acrylicBackgroundColor))
                  ],
                ).marginOnly(bottom: 15),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.error,
                            size: 36,
                            color: Colors.red,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Text(
                            text,
                            style: TextStyle(color: themeController.theme.acrylicBackgroundColor),
                          )),
                        ],
                      )),
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6, horizontal: 28)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  child: const Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _isDialogVisible = false;
                    Get.back();
                  },
                ).marginOnly(bottom: 15),
              ],
            ),
          ),
        ));
      }
    } else {
      InfoBarUtils.showErrorBar(text);
    }
  }

  static showInfoDialog(String text) async {
    if (UserUtils.appContext != null) {
      if (!_isDialogVisible) {
        _isDialogVisible = true;
        Get.dialog(ContentDialog(
          style: themeController.theme.dialogTheme,
          content: Container(
            height: 180,
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          _isDialogVisible = false;
                          Get.back();
                        },
                        icon: Icon(FluentIcons.cancel, color: themeController.theme.acrylicBackgroundColor))
                  ],
                ).marginOnly(bottom: 15),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.info,
                            size: 36,
                            color: themeController.theme.focusTheme.glowColor,
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Text(
                            text,
                            style: TextStyle(color: themeController.theme.acrylicBackgroundColor),
                          )),
                        ],
                      )),
                ),
                Button(
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Common.tradeCloseButtonColor),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 6, horizontal: 28)),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
                  child: const Text(
                    "确定",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _isDialogVisible = false;
                    Get.back();
                  },
                ).marginOnly(bottom: 15),
              ],
            ),
          ),
        ));
      }
    } else {
      InfoBarUtils.showInfoBar(text);
    }
  }
}
