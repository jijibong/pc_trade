import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:trade/util/shared_preferences/shared_preferences_key.dart';
import 'package:trade/util/shared_preferences/shared_preferences_utils.dart';

import '../../config/common.dart';

class ThemeController extends GetxController {
  // 当前主题模式
  var isDarkMode = false.obs;
  var multiScreen = 1.obs; // 当前分屏
  var selectIndex = 1.obs; // 首页/自选
  Rx<int> selectCommandBarIndex = (-1).obs; // 工具栏

  @override
  void onInit() {
    super.onInit();
    _initPrefs(); // 初始化本地存储并读取状态
  }

  // 初始化SharedPreferences并读取保存的主题状态
  Future<void> _initPrefs() async {
    final savedMode = await SpUtils.getBool(SpKey.isDarkMode);
    isDarkMode.value = savedMode ?? Get.isDarkMode;
    // update();
  }

  // 切换主题
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    update();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    SpUtils.set(SpKey.isDarkMode, isDarkMode.value);
  }

  // 获取当前主题
  FluentThemeData get theme => isDarkMode.value ? darkTheme : lightTheme;

  // 浅色主题
  static final FluentThemeData lightTheme = FluentThemeData(
      brightness: Brightness.light,
      activeColor: Colors.white,
      inactiveColor: Colors.black,
      inactiveBackgroundColor: Common.lightBgColor, //TabBg
      scaffoldBackgroundColor: Common.contentLightBgColor,
      acrylicBackgroundColor: Common.contentDarkBgColor,
      cardColor: Common.lightCommandBarBgColor, //commandBarBg
      selectionColor: Common.lightExchangeTextColor, //exchangeText
      micaBackgroundColor: Common.lightExchangeBgColor, //exchangeBg
      menuColor: Common.checkBoxBorderLightColor,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: Common.selectTabLightBgColor,
        highlightColor: Common.unSelectTabLightBgColor,
      ),
      focusTheme: FocusThemeData(
        glowColor: Common.lightDownColor,
      ),
      bottomNavigationTheme: BottomNavigationThemeData(
        backgroundColor: Common.unSelectTabLightBgColor,
        selectedColor: Common.contentDarkBgColor,
        inactiveColor: Common.inActiveCommodityTextColor,
      ),
      scrollbarTheme: ScrollbarThemeData(thickness: 5, backgroundColor: Common.lightScrollBarColor),
      sliderTheme: SliderThemeData(
        labelBackgroundColor: Common.textBoxBorderLightColor,
        labelForegroundColor: Common.textBoxBorderHighLightLightColor,
      ),
      dialogTheme: ContentDialogThemeData(
          padding: EdgeInsets.all(Common.dialogPadding),
          barrierColor: Common.contentDarkBgColor,
          decoration: BoxDecoration(color: Common.dialogLightBgColor, borderRadius: BorderRadius.circular(Common.dialogBorderRadius))));

  // 深色主题
  static final FluentThemeData darkTheme = FluentThemeData(
      brightness: Brightness.dark,
      activeColor: Colors.black,
      inactiveColor: Colors.white,
      inactiveBackgroundColor: Common.darkBgColor,
      scaffoldBackgroundColor: Common.contentDarkBgColor,
      acrylicBackgroundColor: Common.contentLightBgColor,
      cardColor: Common.darkCommandBarBgColor,
      selectionColor: Common.darkExchangeTextColor,
      micaBackgroundColor: Common.darkExchangeBgColor,
      menuColor: Common.checkBoxBorderDarkColor,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: Common.selectTabDarkBgColor,
        highlightColor: Common.unSelectTabDarkBgColor,
      ),
      focusTheme: FocusThemeData(
        glowColor: Common.darkDownColor,
      ),
      bottomNavigationTheme: BottomNavigationThemeData(
        backgroundColor: Common.selectTabDarkBgColor,
        selectedColor: Colors.white,
        inactiveColor: Common.commandTextColor,
      ),
      scrollbarTheme: ScrollbarThemeData(thickness: 5, backgroundColor: Common.darkScrollBarColor),
      sliderTheme: SliderThemeData(
        labelBackgroundColor: Common.textBoxBorderDarkColor,
        labelForegroundColor: Common.textBoxBorderHighLightDarkColor,
      ),
      dialogTheme: ContentDialogThemeData(
          padding: EdgeInsets.all(Common.dialogPadding),
          barrierColor: Common.dialogContentBorderBgColor,
          decoration: BoxDecoration(color: Common.dialogDarkBgColor, borderRadius: BorderRadius.circular(Common.dialogBorderRadius))));
}
