import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../../model/user/user.dart';
import '../info_bar/info_bar.dart';
import '../log/log.dart';

class HttpUtils {
  static HttpUtils instance = HttpUtils();
  static String token = '';
  static Dio _dio = Dio();
  BaseOptions _options = BaseOptions();

  static HttpUtils getInstance() {
    return instance;
  }

  //初始化
  HttpUtils() {
    _options = BaseOptions(
      baseUrl: Config.URL,
      connectTimeout: Common.connectTimeout,
      receiveTimeout: Common.receiveTimeout,
    );

    _dio = Dio(_options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) async {
        if (UserUtils.currentUser != null && UserUtils.currentUser!.token != null) {
          options.headers['Authorization'] = UserUtils.currentUser!.token;
        }
        logger.i(
            "发送请求-----${options.baseUrl}${options.path}---${options.queryParameters}--${options.headers['Authorization']}--${options.contentType}--${options.data}");
        handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        // 如果你想完成请求并返回一些自定义数据，你可以使用 `handler.resolve(response)`。
        logger.i("响应错误-----$error");
        return handler.next(error);
      },
    ));
  }

  get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    Response response;
    try {
      response = await _dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
    } on DioException catch (err) {
      if (err.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar("网络连接出现异常");
      } else {
        InfoBarUtils.showErrorBar("未知错误，请稍后再试");
      }
      Log.e("get request failed: $path $err ${err.response?.data}", err);
      rethrow;
    }
    return response;
  }

  post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Response response;
    try {
      response =
          await _dio.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      Log.e("post request failed: $path $e ${e.response?.data}", e);
      if (e.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar("网络连接出现异常");
      } else {
        InfoBarUtils.showErrorBar("未知错误，请稍后再试");
      }
      rethrow;
    }
    return response;
  }

  put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Response response;
    try {
      response =
          await _dio.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      if (e.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar("网络连接出现异常");
      } else {
        InfoBarUtils.showErrorBar("未知错误，请稍后再试");
      }
      Log.e("put request failed: $path $e ${e.response?.data}", e);
      rethrow;
    }
    return response;
  }

  delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    Response response;
    try {
      response = await _dio.delete(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
    } on DioException catch (e) {
      if (e.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar("网络连接出现异常");
      }
      Log.e("post request failed: $path $e ${e.response?.data}", e);
      rethrow;
    }
    return response;
  }

  patch(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Response response;
    try {
      response = await _dio.patch(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      if (e.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar("网络连接出现异常");
      }
      Log.e("patch request failed: $path $e ${e.response?.data}", e);
      rethrow;
    }
    return response;
  }

  download(String urlPath, savePath, {Map<String, dynamic>? queryParameters, String lengthHeader = Headers.formUrlEncodedContentType, Options? options}) async {
    Response response;
    try {
      response = await _dio.download(urlPath, savePath, options: options, queryParameters: queryParameters, lengthHeader: lengthHeader);
    } on DioException catch (e) {
      if (e.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar("网络连接出现异常");
      }
      Log.e("download request failed: $urlPath $e ${e.response?.data}", e);
      rethrow;
    }
    return response;
  }

  static Dio createNewDio() {
    return Dio();
  }

  static Dio get dio => _dio;
}
