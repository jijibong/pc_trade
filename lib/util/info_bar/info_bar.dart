import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';

import '../../config/common.dart';
import '../../model/user/user.dart';
import '../theme/theme.dart';

class InfoBarUtils {
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
      final appTheme = AppTheme();
      showDialog(
          context: UserUtils.appContext!,
          builder: (BuildContext context) {
            return ContentDialog(
              style: ContentDialogThemeData(
                  padding: EdgeInsets.zero, bodyPadding: EdgeInsets.zero, decoration: BoxDecoration(color: appTheme.color, borderRadius: BorderRadius.zero)),
              content: Container(
                height: 200,
                color: Common.dialogContentColor,
                alignment: Alignment.center,
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
                              Common.appName,
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
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                              Flexible(child: Text(text)),
                            ],
                          )),
                    ),
                    Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "确定",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      InfoBarUtils.showWarningBar(text);
    }
  }

  static showSuccessDialog(String text) async {
    if (UserUtils.appContext != null) {
      final appTheme = AppTheme();
      showDialog(
          context: UserUtils.appContext!,
          builder: (BuildContext context) {
            return ContentDialog(
              style: ContentDialogThemeData(
                  padding: EdgeInsets.zero, bodyPadding: EdgeInsets.zero, decoration: BoxDecoration(color: appTheme.color, borderRadius: BorderRadius.zero)),
              content: Container(
                height: 200,
                color: Common.dialogContentColor,
                alignment: Alignment.center,
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
                              Common.appName,
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
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                              Flexible(child: Text(text)),
                            ],
                          )),
                    ),
                    Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "确定",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      InfoBarUtils.showSuccessBar(text);
    }
  }

  static showErrorDialog(String text) async {
    if (UserUtils.appContext != null) {
      final appTheme = AppTheme();
      showDialog(
          context: UserUtils.appContext!,
          builder: (BuildContext context) {
            return ContentDialog(
              style: ContentDialogThemeData(
                  padding: EdgeInsets.zero, bodyPadding: EdgeInsets.zero, decoration: BoxDecoration(color: appTheme.color, borderRadius: BorderRadius.zero)),
              content: Container(
                height: 200,
                color: Common.dialogContentColor,
                alignment: Alignment.center,
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
                              Common.appName,
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
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                              Flexible(child: Text(text)),
                            ],
                          )),
                    ),
                    Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "确定",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      InfoBarUtils.showErrorBar(text);
    }
  }

  static showInfoDialog(String text) async {
    if (UserUtils.appContext != null) {
      final appTheme = AppTheme();
      showDialog(
          context: UserUtils.appContext!,
          builder: (BuildContext context) {
            return ContentDialog(
              style: ContentDialogThemeData(
                  padding: EdgeInsets.zero, bodyPadding: EdgeInsets.zero, decoration: BoxDecoration(color: appTheme.color, borderRadius: BorderRadius.zero)),
              content: Container(
                height: 200,
                color: Common.dialogContentColor,
                alignment: Alignment.center,
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
                              Common.appName,
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
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                              Flexible(child: Text(text)),
                            ],
                          )),
                    ),
                    Button(
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Common.dialogButtonTextColor),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 30, vertical: 3)),
                          shape: const WidgetStatePropertyAll(RoundedRectangleBorder())),
                      child: const Text(
                        "确定",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
              ),
            );
          });
    } else {
      InfoBarUtils.showInfoBar(text);
    }
  }
}
