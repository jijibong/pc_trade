import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:trade/model/quote/contract.dart';
import '../../page/quote/quote_logic.dart';
import '../theme/theme.dart';

class ContractDialog {
  final ThemeController themeController = Get.find<ThemeController>();
  final QuoteLogic logic = Get.put(QuoteLogic());

  Widget contractInfoDialog(Contract contract) {
    return ContentDialog(
      style: themeController.theme.dialogTheme,
      constraints: const BoxConstraints(
        maxWidth: 508.0,
        maxHeight: 756.0,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                  child: Text(
                "合约资料",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )),
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(FluentIcons.cancel))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), border: Border.all(color: themeController.theme.dialogTheme.barrierColor!, width: 0.5)),
            child: Column(
              children: [
                item("交易品种", contract.comName),
                item("交易单位", "证券公司"),
                item("报价单位", "交易所"),
                item("最小变动价位", "${contract.futureTickSize}"),
                item("涨跌停板幅度", null),
                item("合约交割月份", null),
                item("交易时间", contract.trTime),
                item("最后交易日", null),
                item("最后交割日", null),
                item("交割品级", null),
                item("交割地点", null),
                item("交割方式", null),
                item("交易代码", null),
                item("最低交易保障金", null),
                item("上市交易所", null),
                item("上市日期", null, needBottomBorder: false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget item(String title, String? content, {bool? needBottomBorder}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: needBottomBorder == false ? Colors.transparent : themeController.theme.dialogTheme.barrierColor!,
            width: 0.75,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: TextStyle(color: themeController.theme.bottomNavigationTheme.inactiveColor, fontSize: 14),
            ),
          ),
          Expanded(
              child: Text(
            content ?? "--",
            style: TextStyle(color: themeController.theme.acrylicBackgroundColor, fontSize: 14),
          )),
        ],
      ),
    );
  }
}
