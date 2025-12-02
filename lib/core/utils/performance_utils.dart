import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance utilities to prevent frame skipping and optimize UI rendering
class PerformanceUtils {
  /// Executes a function after the current frame is complete to prevent blocking UI
  static Future<T> executeAfterFrame<T>(Future<T> Function() function) async {
    final completer = Completer<T>();
    
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await function();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    
    return completer.future;
  }

  /// Executes a function with a timeout and fallback to prevent hanging
  static Future<T> executeWithTimeout<T>(
    Future<T> Function() function,
    Duration timeout, {
    T? fallback,
    String? debugName,
  }) async {
    try {
      return await function().timeout(timeout);
    } catch (e) {
      if (kDebugMode && debugName != null) {
        print('⚠️ $debugName timed out or failed: $e');
      }
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
  }

  /// Batches multiple async operations to prevent overwhelming the main thread
  static Future<List<T>> batchExecute<T>(
    List<Future<T> Function()> functions, {
    int batchSize = 3,
    Duration delayBetweenBatches = const Duration(milliseconds: 50),
  }) async {
    final results = <T>[];
    
    for (int i = 0; i < functions.length; i += batchSize) {
      final batch = functions.skip(i).take(batchSize);
      final batchResults = await Future.wait(
        batch.map((f) => f()),
        eagerError: false,
      );
      
      results.addAll(batchResults);
      
      // Small delay between batches to prevent frame drops
      if (i + batchSize < functions.length) {
        await Future.delayed(delayBetweenBatches);
      }
    }
    
    return results;
  }

  /// Debounces function calls to prevent excessive execution
  static Timer? _debounceTimer;
  
  static void debounce(
    Duration delay,
    VoidCallback callback, {
    String? debugName,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      if (kDebugMode && debugName != null) {
        print('🔄 Executing debounced function: $debugName');
      }
      callback();
    });
  }

  /// Measures execution time for performance monitoring
  static Future<T> measureExecutionTime<T>(
    Future<T> Function() function, {
    String? debugName,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await function();
      stopwatch.stop();
      
      if (kDebugMode && debugName != null) {
        print('⏱️ $debugName executed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      if (kDebugMode && debugName != null) {
        print('❌ $debugName failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      }
      
      rethrow;
    }
  }

  /// Checks if the current platform has performance constraints
  static bool get hasPerformanceConstraints {
    if (kIsWeb) return true; // Web can be slower
    return false; // Mobile is generally faster
  }

  /// Gets platform-optimized timeout duration
  static Duration get platformOptimizedTimeout {
    if (kIsWeb) {
      return const Duration(seconds: 20); // Longer timeout for web
    } else {
      return const Duration(seconds: 10); // Shorter timeout for mobile
    }
  }

  /// Gets platform-optimized batch size for operations
  static int get platformOptimizedBatchSize {
    if (kIsWeb) {
      return 2; // Smaller batches for web
    } else {
      return 5; // Larger batches for mobile
    }
  }
}
