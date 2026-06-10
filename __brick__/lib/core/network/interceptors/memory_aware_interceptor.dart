import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../services/memory/memory_manager.dart';
import '../../../utils/helpers/colored_print.dart';

/// Interceptor that adds memory-friendly headers and cooperates with
/// [MemoryManager] to avoid keeping large responses in memory.
@lazySingleton
class MemoryAwareInterceptor extends Interceptor {
  MemoryAwareInterceptor() : maxResponseSizeBytes = 10 * 1024 * 1024;

  final int maxResponseSizeBytes;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final memoryManager = MemoryManager();
    if (memoryManager.isMemoryHigh) {
      printY(
        'MemoryAwareInterceptor: high memory detected, clearing caches before request',
      );
      memoryManager.clearAllCaches();
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final contentLengthHeader = response.headers.value('content-length');
    if (contentLengthHeader != null) {
      final size = int.tryParse(contentLengthHeader);
      if (size != null && size > maxResponseSizeBytes) {
        printR(
          'MemoryAwareInterceptor: response too large ($size bytes), rejecting',
        );
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error:
                'Response too large: $size bytes (max: $maxResponseSizeBytes bytes)',
          ),
        );
        return;
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionTimeout) {
      printY('MemoryAwareInterceptor: timeout detected, clearing image cache');
      MemoryManager().clearImageCache();
    }

    handler.next(err);
  }
}
