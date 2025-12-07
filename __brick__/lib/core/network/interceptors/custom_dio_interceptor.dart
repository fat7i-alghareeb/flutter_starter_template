import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../utils/helpers/colored_print.dart';

enum BoxStyle { unicode, ascii, simple }

@lazySingleton
class CustomDioInterceptor extends Interceptor {
  CustomDioInterceptor({
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.logErrors = true,
    this.maxBodyChars = 2000,
    this.redactedHeaders = const ['authorization', 'cookie'],
    this.boxStyle = BoxStyle.ascii, // change this if you want unicode
  });

  final bool logRequestHeaders;
  final bool logRequestBody;
  final bool logResponseHeaders;
  final bool logResponseBody;
  final bool logErrors;
  final int maxBodyChars;
  final List<String> redactedHeaders;
  final BoxStyle boxStyle;

  static final _jsonEncoder = JsonEncoder.withIndent('  ');

  String _redactHeaders(Map<String, dynamic> headers) {
    final Map<String, dynamic> copy = {};
    headers.forEach((k, v) {
      if (redactedHeaders.contains(k.toLowerCase())) {
        copy[k] = '***REDACTED***';
      } else {
        copy[k] = v;
      }
    });
    return copy.toString();
  }

  String _truncate(String text) {
    if (text.length <= maxBodyChars) return text;
    return '${text.substring(0, maxBodyChars)}\n... (truncated, total ${text.length} chars)';
  }

  String _prettyData(Object? data) {
    try {
      if (data == null) return 'null';
      if (data is FormData) {
        final buf = StringBuffer();
        for (final f in data.fields) {
          buf.writeln('${f.key}: ${f.value}');
        }
        for (final f in data.files) {
          final filename = f.value.filename ?? '<file>';
          buf.writeln('${f.key}: <file: $filename>');
        }
        return buf.toString();
      }
      if (data is String) {
        // try parse JSON
        final trimmed = data.trim();
        if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
            (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
          final decoded = json.decode(trimmed);
          return _jsonEncoder.convert(decoded);
        }
        return data;
      }
      // If it's a Map/List or encodable, pretty print JSON
      if (data is Map || data is List) {
        return _jsonEncoder.convert(data);
      }

      // Fallback to toString()
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }

  // Build a nice box depending on chosen style.
  void _box(void Function(Object?) printFn, String title, String body) {
    switch (boxStyle) {
      case BoxStyle.unicode:
        printFn('╔' + '═' * 86);
        printFn('║ $title');
        printFn('╟' + '─' * 86);
        for (final line in body.trim().split('\n')) {
          printFn('║ $line');
        }
        printFn('╚' + '═' * 86);
        break;
      case BoxStyle.ascii:
        printFn('+' + '=' * 86 + '+');
        printFn('| $title');
        printFn('+' + '-' * 86 + '+');
        for (final line in body.trim().split('\n')) {
          printFn('| $line');
        }
        printFn('+' + '=' * 86 + '+');
        break;
      case BoxStyle.simple:
      // ignore: unreachable_switch_default
      default:
        printFn('----- $title -----');
        for (final line in body.trim().split('\n')) {
          printFn(line);
        }
        printFn('----- end $title -----');
        break;
    }
  }

  String _curlCommand(RequestOptions options) {
    final buffer = StringBuffer();
    final uri = options.uri.toString();
    buffer.write('curl -X ${options.method.toUpperCase()}');

    // headers
    options.headers.forEach((k, v) {
      final kl = k.toLowerCase();
      if (redactedHeaders.contains(kl)) return;
      // If header value is multiple entries, join with ", "
      buffer.write(' -H "${k}: ${v is List ? v.join(', ') : v}"');
    });

    if (options.data != null && options.data is! FormData) {
      try {
        final bodyStr = options.data is String
            ? options.data
            : json.encode(options.data);
        buffer.write(" -d '${bodyStr.replaceAll("'", "\\'")}'");
      } catch (_) {
        // ignore
      }
    }

    buffer.write(" '$uri'");
    return buffer.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    void Function(Object?) colorLogger;
    switch (method) {
      case 'GET':
        colorLogger = printC;
        break;
      case 'POST':
        colorLogger = printG;
        break;
      case 'PUT':
        colorLogger = printY;
        break;
      case 'DELETE':
        colorLogger = printR;
        break;
      default:
        colorLogger = printW;
        break;
    }

    // save start time so we can compute total latency on response/error
    options.extra['__request_start_time'] = DateTime.now();

    final sb = StringBuffer();
    sb.writeln('📤 [REQUEST] $method ${options.uri}');
    sb.writeln();

    // Curl preview (helpful for reproducing issues outside the app).
    final curl = _truncate(_curlCommand(options));
    sb.writeln('💻 Curl:');
    sb.writeln(curl);
    sb.writeln();

    if (logRequestHeaders && options.headers.isNotEmpty) {
      sb.writeln('📋 Headers:');
      sb.writeln(_redactHeaders(Map<String, dynamic>.from(options.headers)));
      sb.writeln();
    }

    if (logRequestBody && options.data != null) {
      final pretty = _prettyData(options.data);
      sb.writeln('📦 Body:');
      sb.writeln(_truncate(pretty));
    }

    _box(colorLogger, '📤 REQUEST [$method]', sb.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start =
        response.requestOptions.extra['__request_start_time'] as DateTime?;
    final duration = start == null ? null : DateTime.now().difference(start);

    final sb = StringBuffer();
    sb.writeln(
      '📥 [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}',
    );
    sb.writeln();

    if (duration != null) {
      sb.writeln('⏱️ Timing: ${duration.inMilliseconds} ms');
      sb.writeln();
    }

    if (logResponseHeaders && response.headers.map.isNotEmpty) {
      sb.writeln('📋 Headers:');
      sb.writeln(response.headers.map.toString());
      sb.writeln();
    }

    if (logResponseBody && response.data != null) {
      final pretty = _prettyData(response.data);
      sb.writeln('📦 Data:');
      sb.writeln(_truncate(pretty));
    }

    _box(printM, '📥 RESPONSE [${response.statusCode}]', sb.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!logErrors) return handler.next(err);

    final start = err.requestOptions.extra['__request_start_time'] as DateTime?;
    final duration = start == null ? null : DateTime.now().difference(start);

    final sb = StringBuffer();
    sb.writeln('❌ [ERROR] ${err.requestOptions.uri}');
    sb.writeln();

    if (err.response?.statusCode != null) {
      sb.writeln('📡 Status: ${err.response?.statusCode}');
    }
    if (duration != null) {
      sb.writeln('⏱️ Timing: ${duration.inMilliseconds} ms');
    }
    if (err.message != null) {
      sb.writeln('💬 Message: ${err.message}');
    }
    if (err.response?.data != null) {
      final pretty = _prettyData(err.response?.data);
      sb.writeln();
      sb.writeln('📦 Response data:');
      sb.writeln(_truncate(pretty));
    }

    _box(printR, '❌ ERROR', sb.toString());
    handler.next(err);
  }
}
