import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import '../../config/common.dart';
import '../../model/message/message.dart';
import '../../util/theme/theme.dart';

class MessagePage extends StatefulWidget {
  final List<MessageDate> messageList; //消息通知

  const MessagePage(this.messageList, {super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        appBar: NavigationAppBar(
          height: 60,
          automaticallyImplyLeading: false,
          backgroundColor: themeController.isDarkMode.value ? Common.darkBgColor : Common.contentLightBgColor,
          title: () {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: [
                    IconButton(icon: const Icon(FluentIcons.back), onPressed: () => Get.back()),
                    const Text(
                      "全部消息通知",
                      style: TextStyle(fontSize: 14),
                    ).marginSymmetric(horizontal: 18),
                    Text(
                      "全部标记为已读",
                      style: TextStyle(color: Common.hyperlinkColor, fontSize: 14),
                    )
                  ],
                ),
              ),
            );
          }(),
        ),
        content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            decoration: BoxDecoration(
              color: themeController.isDarkMode.value ? Common.darkBgColor : Common.contentLightBgColor,
              border: Border(
                top: BorderSide(
                  color: themeController.isDarkMode.value ? Common.msgDividerDarkBgColor : Common.textBoxBorderLightColor,
                  width: 1,
                ),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              decoration: BoxDecoration(
                color: themeController.isDarkMode.value ? Common.msgDarkBgColor : Common.contentLightBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: themeController.isDarkMode.value ? Colors.transparent : Common.textBoxBorderLightColor,
                  width: 1,
                ),
              ),
              child: ListView.builder(
                  itemCount: widget.messageList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (widget.messageList[index].selected == true) {
                          return;
                        }
                        for (var element in widget.messageList) {
                          element.selected = false;
                        }
                        widget.messageList[index].selected = true;
                        setState(() {});
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.messageList[index].selected == true
                                ? (themeController.isDarkMode.value ? Common.dialogDarkBgColor : Common.tradeButtonColor)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                color: widget.messageList[index].read == true ? Colors.transparent : themeController.theme.focusTheme.glowColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ).marginOnly(right: 12),
                            Expanded(
                              child: Text(
                                widget.messageList[index].message ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              widget.messageList[index].time ?? "",
                              style: TextStyle(
                                  color: themeController.isDarkMode.value ? Common.commandTextColor : Common.msgTimeLightColor, fontSize: 14),
                            ).marginOnly(left: 12),
                          ])),
                    );
                  }),
            )));
  }
}
