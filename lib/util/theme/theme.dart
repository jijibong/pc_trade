import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../config/common.dart';

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  Color _color = Colors.white;
  Color get color => _color;
  Color _unColor = Colors.black;
  Color get unColor => _unColor;
  Color _commandBarColor = Common.darkCommandBarColor;
  Color get commandBarColor => _commandBarColor;
  // Color _quoteColor = Common.darkCommandBarColor;
  // Color get quoteColor => _quoteColor;
  colorRefresh(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      _color = Colors.black;
      _unColor = Colors.white;
      _commandBarColor = Common.lightCommandBarColor;
    } else {
      _color = Colors.white;
      _unColor = Colors.black;
      _commandBarColor = Common.darkCommandBarColor;
    }
  }

  Color _exchangeTextColor = Common.exchangeTextColor;
  Color get exchangeTextColor => _exchangeTextColor;
  Color _exchangeBgColor = Common.exchangeBgColor;
  Color get exchangeBgColor => _exchangeBgColor;
  set exchangeTextColor(Color exchangeTextColor) {
    _exchangeTextColor = exchangeTextColor;
    notifyListeners();
  }

  set exchangeBgColor(Color exchangeBgColor) {
    _exchangeBgColor = exchangeBgColor;
    notifyListeners();
  }

  Color _drawColor = Colors.white;
  Color get drawColor => _drawColor;
  set drawColor(Color drawColor) {
    _drawColor = drawColor;
    notifyListeners();
  }

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    colorRefresh(mode);
    notifyListeners();
  }

  int _selectCommandBarIndex = -1;
  int get selectCommandBarIndex => _selectCommandBarIndex;
  set selectCommandBarIndex(int selectCommandBarIndex) {
    _selectCommandBarIndex = selectCommandBarIndex;
    notifyListeners();
  }

  int _selectIndex = 1;
  int get selectIndex => _selectIndex;
  set selectIndex(int selectIndex) {
    _selectIndex = selectIndex;
    notifyListeners();
  }

  int _viewIndex = 0;
  int get viewIndex => _viewIndex;
  set viewIndex(int viewIndex) {
    _viewIndex = viewIndex;
    notifyListeners();
  }

  int _tradeIndex = 0;
  int get tradeIndex => _tradeIndex;
  set tradeIndex(int tradeIndex) {
    _tradeIndex = tradeIndex;
    notifyListeners();
  }

  int _tradeDetailIndex = 0;
  int get tradeDetailIndex => _tradeDetailIndex;
  set tradeDetailIndex(int tradeDetailIndex) {
    _tradeDetailIndex = tradeDetailIndex;
    notifyListeners();
  }

  int _tradeAllIndex = 0;
  int get tradeAllIndex => _tradeAllIndex;
  set tradeAllIndex(int tradeAllIndex) {
    _tradeAllIndex = tradeAllIndex;
    notifyListeners();
  }

  PaneDisplayMode _displayMode = PaneDisplayMode.auto;
  PaneDisplayMode get displayMode => _displayMode;
  set displayMode(PaneDisplayMode displayMode) {
    _displayMode = displayMode;
    notifyListeners();
  }

  CommandBarItemDisplayMode _commandBarItemDisplayMode = CommandBarItemDisplayMode.inPrimaryCompact;
  CommandBarItemDisplayMode get commandBarItemDisplayMode => _commandBarItemDisplayMode;
  set commandBarItemDisplayMode(CommandBarItemDisplayMode commandBarItemDisplayMode) {
    _commandBarItemDisplayMode = commandBarItemDisplayMode;
    notifyListeners();
  }

  NavigationIndicators _indicator = NavigationIndicators.sticky;
  NavigationIndicators get indicator => _indicator;
  set indicator(NavigationIndicators indicator) {
    _indicator = indicator;
    notifyListeners();
  }

  WindowEffect _windowEffect = WindowEffect.disabled;
  WindowEffect get windowEffect => _windowEffect;
  set windowEffect(WindowEffect windowEffect) {
    _windowEffect = windowEffect;
    notifyListeners();
  }

  void setEffect(WindowEffect effect, BuildContext context) {
    Window.setEffect(
      effect: effect,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
      ].contains(effect)
          ? FluentTheme.of(context).micaBackgroundColor.withOpacity(0.05)
          : Colors.transparent,
      dark: FluentTheme.of(context).brightness.isDark,
    );
  }

  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }

  Locale _locale = const Locale('zh', 'CN');
  Locale get locale => _locale;
  set locale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

// AccentColor get systemAccentColor {
//   if ((defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.android) && !kIsWeb) {
//     return AccentColor.swatch({
//       'darkest': SystemTheme.accentColor.darkest,
//       'darker': SystemTheme.accentColor.darker,
//       'dark': SystemTheme.accentColor.dark,
//       'normal': SystemTheme.accentColor.accent,
//       'light': SystemTheme.accentColor.light,
//       'lighter': SystemTheme.accentColor.lighter,
//       'lightest': SystemTheme.accentColor.lightest,
//     });
//   }
//   return Colors.yellow;
// }
