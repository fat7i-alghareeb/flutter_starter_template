import 'package:flutter/widgets.dart';

/// Minimal memory helper used by [MemoryAwareInterceptor].
///
/// This is intentionally lightweight and focuses on clearing Flutter
/// image caches when we detect large responses or timeouts.
class MemoryManager {
  /// Very naive heuristic for high memory – can be extended later to
  /// read from platform channels or other metrics.
  bool get isMemoryHigh => false;

  /// Clears all relevant in-process caches.
  void clearAllCaches() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Clears only image caches.
  void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
