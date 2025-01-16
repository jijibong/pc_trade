import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../config/common.dart';
import '../../config/config.dart';
import '../../main.dart';
import '../../model/condition/condition.dart';
import '../../model/quote/order_type.dart';
import '../../model/quote/position_effect_type.dart';
import '../../model/quote/side_type.dart';
import '../../model/user/user.dart';
import '../../server/condition/condition.dart';
import '../../util/http/http.dart';
import '../../util/info_bar/info_bar.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/shared_preferences/shared_preferences_key.dart';
import '../../util/shared_preferences/shared_preferences_utils.dart';
import '../../util/widget/number_box.dart';

class LocalNotification extends StatefulWidget {
  final Map<String, dynamic> params;

  const LocalNotification({super.key, required this.params});

  @override
  State<LocalNotification> createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> with MultiWindowListener {
  int windowId() {
    return widget.params["windowId"];
  }

  void startDragging(bool isMainWindow) {
    if (isMainWindow) {
      windowManager.startDragging();
    } else {
      WindowController.fromWindowId(kWindowId!).startDragging();
    }
  }

  void setMovable(bool isMainWindow, bool movable) {
    if (isMainWindow) {
      windowManager.setMovable(movable);
    } else {
      WindowController.fromWindowId(kWindowId!).setMovable(movable);
    }
  }

  initData() async {
    rustDeskWinManager.setMethodHandler((call, fromWindowId) async {
      if (call.method == kWindowEventNewDraw) {
        windowOnTop(windowId());
      }
    });
  }

  @override
  void onWindowClose() async {
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
      await rustDeskWinManager.call(WindowType.Main, kWindowEventHide, {"id": kWindowId!});
    }

    final controller = WindowController.fromWindowId(kWindowId!);
    await notMainWindowClose(controller);
    super.onWindowClose();
  }

  @override
  void initState() {
    super.initState();
    DesktopMultiWindow.addListener(this);
    initData();
  }

  @override
  void dispose() {
    DesktopMultiWindow.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
          automaticallyImplyLeading: false,
          height: 30,
          title: GestureDetector(
            onPanStart: (_) => startDragging(false),
            onPanCancel: () {
              if (isMacOS) {
                setMovable(false, false);
              }
            },
            onPanEnd: (_) {
              if (isMacOS) {
                setMovable(false, false);
              }
            },
            child: Row(children: [
              Image.asset('assets/images/jmaster.ico', width: 16, height: 16),
              Expanded(
                  child: const Text(
                    "画线工具箱",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ).marginOnly(left: 2))
            ]).marginOnly(
              left: 2,
              right: 2,
            ),
          ),
          actions: IconButton(
              icon: const Icon(
                FluentIcons.chrome_close,
                color: Colors.white,
              ),
              onPressed: () {
                Future.delayed(Duration.zero, () async {
                  await WindowController.fromWindowId(kWindowId!).close();
                });
              })),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
