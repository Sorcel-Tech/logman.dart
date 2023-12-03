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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Map<String, String>? responseHeaders = err.response?.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );

    final requestRecord = NetworkRequestLogmanRecord(
      url: err.requestOptions.uri.toString(),
      method: err.requestOptions.method,
      headers: err.requestOptions.headers,
      body: err.requestOptions.data,
    );

    final responseRecord = NetworkResponseLogmanRecord(
      statusCode: err.response?.statusCode ?? 0,
      headers: responseHeaders,
      body: err.response?.data,
    );

    _logman.recordNetwork(NetworkLogmanRecord(
      request: requestRecord,
      response: responseRecord,
    ));

    return super.onError(err, handler);
  }
}
