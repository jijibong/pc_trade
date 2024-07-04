import 'package:logger/logger.dart';

final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 10,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    )
);

class Log {
  static t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // debugPrint(message);
    logger.t(message, error: error, stackTrace: stackTrace);
  }

  static d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // debugPrint(message);
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  static i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // debugPrint(message);
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  static w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // debugPrint(message);
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  static e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // debugPrint(message);
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // debugPrint(message);
    logger.f(message, error: error, stackTrace: stackTrace);
  }
}