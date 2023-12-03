import 'package:dio/dio.dart';
import 'package:logman/logman.dart';

class LogmanDioInterceptor extends Interceptor {
  final Logman _logman = Logman.instance;

  LogmanDioInterceptor();

  final _cache = <RequestOptions, DateTime>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _cache[options] = DateTime.now();
    _logman.recordSimpleLog('Request sent to ${options.uri.toString()}');

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Map<String, String> responseHeaders = response.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
    final sentAt = _cache[response.requestOptions];
    final receivedAt = DateTime.now();

    final requestRecord = NetworkRequestLogmanRecord(
      url: response.requestOptions.uri.toString(),
      method: response.requestOptions.method,
      headers: response.requestOptions.headers,
      body: response.requestOptions.data,
      sentAt: sentAt,
    );

    final responseRecord = NetworkResponseLogmanRecord(
      statusCode: response.statusCode,
      headers: responseHeaders,
      body: response.data,
      receivedAt: receivedAt,
    );

    _logman.recordNetwork(NetworkLogmanRecord(
      request: requestRecord,
      response: responseRecord,
    ));

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException exception, ErrorInterceptorHandler handler) {
    final Map<String, String>? responseHeaders =
        exception.response?.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );

    final requestRecord = NetworkRequestLogmanRecord(
      url: exception.requestOptions.uri.toString(),
      method: exception.requestOptions.method,
      headers: exception.requestOptions.headers,
      body: exception.requestOptions.data,
    );

    final responseRecord = NetworkResponseLogmanRecord(
      statusCode: exception.response?.statusCode ?? 0,
      headers: responseHeaders,
      body: exception.response?.data,
    );

    _logman.recordNetwork(NetworkLogmanRecord(
      request: requestRecord,
      response: responseRecord,
    ));

    return super.onError(exception, handler);
  }
}
