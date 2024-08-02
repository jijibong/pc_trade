import 'package:fluent_ui/fluent_ui.dart';

import '../../model/user/user.dart';

class InfoBarUtils {
  static showWarningBar(String text) async {
    if (UserUtils.appContext != null) {
      await displayInfoBar(UserUtils.appContext!, builder: (context, close) {
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
}
