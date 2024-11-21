import 'package:dio/dio.dart';
import '../../config/common.dart';
import '../../config/config.dart';
import '../info_bar/info_bar.dart';
import '../log/log.dart';

class MdHttpUtils {
  static MdHttpUtils instance = MdHttpUtils();
  static String token = '';
  static Dio _dio = Dio();
  BaseOptions _options = BaseOptions();

  static MdHttpUtils getInstance() {
    return instance;
  }

  //初始化
  MdHttpUtils() {
    _options = BaseOptions(
      baseUrl: Config.MdURL,
      connectTimeout: Common.connectTimeout,
      receiveTimeout: Common.receiveTimeout,
    );

    _dio = Dio(_options);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (
        RequestOptions options,
        RequestInterceptorHandler handler,
      ) async {
        // if (options.data != null) {
        //   String json = jsonEncode(options.data);
        //   options.data = SignData().signData(json, options.path);
        // }
        // options.headers['Access-Control-Allow-Origin'] = '*';
        logger.d("发送请求-----${options.baseUrl}${options.path}---${options.queryParameters}--${options.contentType}--${options.data}");
        handler.next(options);
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
        InfoBarUtils.showErrorBar( "网络连接出现异常");
      } else {
        InfoBarUtils.showErrorBar( "未知错误，请稍后再试");
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
      if (e.message!.contains('SocketException')) {
        InfoBarUtils.showErrorBar( "网络连接出现异常");
      } else {
        InfoBarUtils.showErrorBar( "未知错误，请稍后再试");
      }
      Log.e("post request failed: $path $e ${e.response?.data}", e);
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
        InfoBarUtils.showErrorBar( "网络连接出现异常");
      } else {
        InfoBarUtils.showErrorBar( "未知错误，请稍后再试");
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
        InfoBarUtils.showErrorBar( "网络连接出现异常");
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
        InfoBarUtils.showErrorBar( "网络连接出现异常");
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
        InfoBarUtils.showErrorBar( "网络连接出现异常");
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
