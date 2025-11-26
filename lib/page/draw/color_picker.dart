import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../main.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';

class ColorPickerPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const ColorPickerPage({super.key, required this.params});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> with MultiWindowListener {
  Color selectedColor = Colors.white;

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
      if (call.method == kWindowEventNewColorPicker) {
        windowOnTop(windowId());
      }
    });
  }

  @override
  void onWindowClose() async {
    notMainWindowClose(WindowController windowController) async {
      await windowController.hide();
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
                // Image.asset('assets/images/jmaster.ico', width: 16, height: 16),
                const Text(
                  "颜色",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ).marginOnly(left: 2)
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
                    await WindowController.fromWindowId(kWindowId!).hide();
                  });
                })),
        content: Column(
          children: [
            ColorPicker(
                color: selectedColor,
                onChanged: (color) => setState(() => selectedColor = color),
                colorSpectrumShape: ColorSpectrumShape.box,
                isMoreButtonVisible: false,
                orientation: Axis.horizontal),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 5))),
                  onPressed: () {
                    Future.delayed(Duration.zero, () async {
                      await WindowController.fromWindowId(kWindowId!).hide();
                      if (widget.params["windowId"] != null) {
                        await DesktopMultiWindow.invokeMethod(
                            widget.params["preWindowId"], kWindowEventSelectColor, {"color": selectedColor.colorValue});
                      }
                    });
                  },
                  child: const Text(
                    '确定',
                  ),
                ),
                Button(
                  style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 5))),
                  onPressed: () {
                    Future.delayed(Duration.zero, () async {
                      await WindowController.fromWindowId(kWindowId!).hide();
                    });
                  },
                  child: const Text(
                    "取消",
                  ),
                ),
              ],
            ).marginOnly(top: 20)
          ],
        ).paddingAll(10));
  }
}
