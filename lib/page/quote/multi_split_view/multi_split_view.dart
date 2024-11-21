import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:trade/page/quote/quote_data.dart';

import '../../../util/theme/theme.dart';

class EmptyView extends StatefulWidget {
  final int? empty;
  const EmptyView({this.empty, super.key});

  @override
  State<EmptyView> createState() => _EmptyViewState();
}

class _EmptyViewState extends State<EmptyView> {
  final MultiSplitViewController _controller = MultiSplitViewController();
  late AppTheme appTheme;
  int empty = 0;

  init() {
    if (widget.empty != null) {
      empty = widget.empty!;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appTheme = context.watch<AppTheme>();
    return MultiSplitView(axis: Axis.vertical, resizable: false, controller: _controller, builder: (BuildContext context, Area area) => area.data);
  }

  Widget item() {
    if (empty == 0) {
      return ContextMenuWidget(
          menuProvider: (_) {
            return Menu(children: [
              Menu(title: '变化窗口', children: [
                MenuAction(
                    title: '报价画面',
                    callback: () {
                      empty = 1;
                      if (mounted) setState(() {});
                    }),
                MenuAction(title: '分时图', callback: () {}),
                MenuAction(title: 'K线图', callback: () {}),
              ]),
              MenuAction(
                  title: '关闭窗口',
                  callback: () {
                    if (mounted) setState(() {});
                  }),
            ]);
          },
          child: Container(
            alignment: Alignment.topLeft,
            width: 1.sw,
            height: 1.sh,
            color: Colors.transparent,
            child: Container(
                margin: EdgeInsets.all(5.sp),
                padding: EdgeInsets.all(2.sp),
                decoration: BoxDecoration(border: Border.all(color: appTheme.color)),
                child: AutoSizeText(
                  "单击鼠标右键，在弹出的菜单中指定窗口内容。",
                  style: TextStyle(color: appTheme.color),
                )),
          ));
    } else if (empty == 1) {
      return const QuoteDatas();
    } else {
      return Container();
    }
  }
}
