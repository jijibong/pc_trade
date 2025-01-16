class ButtonUtil {
  static DateTime? lastPopTime;

  static bool checkClick({int needTime = 500}) {
    if (lastPopTime == null || DateTime.now().difference(lastPopTime!) > Duration(milliseconds: needTime)) {
      lastPopTime = DateTime.now();
      return true;
    }
    return false;
  }
}
