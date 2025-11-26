import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart' hide NumberBox;
import 'package:get/get.dart' hide Condition;
import 'package:trade/util/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../../main.dart';
import '../../model/option/sector.dart';
import '../../util/dialog/add_sector_dialog.dart';
import '../../util/log/log.dart';
import '../../util/multi_windows_manager/common.dart';
import '../../util/multi_windows_manager/consts.dart';
import '../../util/multi_windows_manager/multi_window_manager.dart';
import '../../util/utils/utils.dart';

class SectorManage extends StatefulWidget {
  final Map<String, dynamic> params;

  const SectorManage({super.key, required this.params});

  @override
  State<SectorManage> createState() => _SectorManageState();
}

class _SectorManageState extends State<SectorManage> with MultiWindowListener {
  final ThemeController themeController = Get.find<ThemeController>();
  List<Sector> sectorList = [];

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
      if (call.method == kWindowEventSectorManage) {
        windowOnTop(windowId());
      }
    });

    if (widget.params['hold'] != null && widget.params['hold'] != "") {
      try {
        sectorList.clear();
        final decoded = jsonDecode(widget.params['hold']);
        for (var i in decoded) {
          sectorList.add(Sector.fromJson(i));
        }
        // sectorList.addAll(decoded.map((e) => Sector.fromJson(e)).toList());
      } catch (e) {
        logger.f(e);
        return {};
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void onWindowClose() async {
    await WindowController.fromWindowId(kWindowId!).hide();
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
          backgroundColor:  themeController.theme.cardColor,
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
              Expanded(
                  child: const Text(
                "管理板块",
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
                  await WindowController.fromWindowId(kWindowId!).hide();
                });
              })),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Column(
              children: [
                Row(
                  children: [titleItem("显示"), titleItem("名称", flex: 3), titleItem("删除"), titleItem("分类")],
                ),
                Expanded(
                    child: ReorderableListView.builder(
                  itemCount: sectorList.length,
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return Container(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    TextEditingController controller = TextEditingController(text: sectorList[index].name);
                    return ReorderableDragStartListener(
                        key: Key('$index'),
                        index: index,
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              contentItem(Checkbox(
                                  checked: sectorList[index].show,
                                  onChanged: (e) {
                                    sectorList[index].show = e;
                                    if (mounted) setState(() {});
                                  })),
                              contentItem(
                                  flex: 3,
                                  noPadding: true,
                                  TextBox(
                                    padding: EdgeInsets.zero,
                                    controller: controller,
                                    decoration: WidgetStatePropertyAll(BoxDecoration(border: Border.all(color: Colors.transparent))),
                                    readOnly: sectorList[index].canDelete != true,
                                  )),
                              contentItem(sectorList[index].canDelete == true
                                  ? IconButton(
                                      icon: const Icon(FluentIcons.cancel),
                                      onPressed: () {
                                        sectorList.removeAt(index);
                                        if (mounted) setState(() {});
                                      })
                                  : Container()),
                              contentItem(Text(
                                sectorList[index].type == 0 ? "系统板块" : "自建板块",
                                textAlign: TextAlign.center,
                              )),
                            ],
                          ),
                        ));
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      sectorList.insert(newIndex, sectorList.removeAt(oldIndex));
                    });
                  },
                ))
              ],
            ),
          )),
          Row(
            children: [
              Button(
                  child: const Text("新建板块"),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddSectorDialog().addSectorDialog((e) {
                            Sector newSector = Sector(name: e, type: 1, show: true, canDelete: true, editable: true, id: Utils.generateLenString(10));
                            sectorList.add(newSector);
                            if (mounted) setState(() {});
                          });
                        });
                  }),
              const Spacer(),
              Button(
                  child: const Text("确定"),
                  onPressed: () async {
                    String jsonString = jsonEncode(sectorList.map((e) => e.toJson()).toList());
                    await DesktopMultiWindow.invokeMethod(kMainWindowId, kWindowEventSectorManageEvent, {"sectorList": jsonString});
                    Future.delayed(Duration.zero, () async {
                      await WindowController.fromWindowId(kWindowId!).hide();
                    });
                  }).marginOnly(right: 10),
              Button(
                  child: const Text("取消"),
                  onPressed: () {
                    Future.delayed(Duration.zero, () async {
                      await WindowController.fromWindowId(kWindowId!).hide();
                    });
                  })
            ],
          ).marginOnly(top: 10)
        ],
      ).marginAll(10),
    );
  }

  Widget titleItem(String text, {int? flex}) {
    return Expanded(
        flex: flex ?? 1,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          child: Text(text),
        ));
  }

  Widget contentItem(Widget child, {int? flex, bool? noPadding}) {
    return Expanded(
        flex: flex ?? 1,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          alignment: Alignment.center,
          padding: noPadding == true ? EdgeInsets.zero : const EdgeInsets.all(3),
          child: child,
        ));
  }
}
