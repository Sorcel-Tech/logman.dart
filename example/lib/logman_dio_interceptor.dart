import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logman/logman.dart';

class LogmanDioInterceptor extends Interceptor {
  final Logman _logman = Logman.instance;

  LogmanDioInterceptor();

  final _cache = <RequestOptions, String>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestId = UniqueKey().toString();
    _cache[options] = requestId;
    final sentAt = DateTime.now();

    final requestRecord = NetworkRequestLogmanRecord(
      id: requestId,
      url: options.uri.toString(),
      method: options.method,
      headers: options.headers,
      body: dataToString(options.data),
      sentAt: sentAt,
    );
    _logman.networkRequest(requestRecord);

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Map<String, String> responseHeaders = response.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
    final id = _cache[response.requestOptions];
    final receivedAt = DateTime.now();

    final responseRecord = NetworkResponseLogmanRecord(
      id: id!,
      statusCode: response.statusCode,
      headers: responseHeaders,
      body: dataToString(response.data),
      receivedAt: receivedAt,
    );

    _logman.networkResponse(responseRecord);

    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Map<String, String>? responseHeaders = err.response?.headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
    final id = _cache[err.requestOptions];

    final responseRecord = NetworkResponseLogmanRecord(
      id: id!,
      statusCode: err.response?.statusCode ?? 0,
      headers: responseHeaders,
      body: dataToString(err.response?.data),
      receivedAt: DateTime.now(),
    );

    _logman.networkResponse(responseRecord);

    return super.onError(err, handler);
  }

  String dataToString(dynamic data) {
    if (data is Map) {
      return jsonEncode(data);
    } else if (data is List) {
      return jsonEncode(data);
    } else {
      if (data is FormData) {
        return readFormData(data);
      }
      return data.toString();
    }
  }

  String readFormData(FormData formData) {
    Map<String, dynamic> formDataMap = {};
    for (var field in formData.fields) {
      formDataMap[field.key] = field.value;
    }

    // Convert the map to a formatted JSON string
    return jsonEncode(formDataMap);
  }
}
