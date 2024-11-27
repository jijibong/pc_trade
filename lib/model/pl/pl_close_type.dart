import 'dart:convert';

class PLCloseType {
  //当日有效
  static final int Today = ascii.encode('T').first; //84
  //永久有效
  static final int Permanent = ascii.encode('A').first; //65
}
