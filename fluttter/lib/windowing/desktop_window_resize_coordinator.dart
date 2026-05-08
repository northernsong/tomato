import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'tomato_platform.dart';

/// 将测量到的 Flutter 布局尺寸同步到原生窗口，带节流与收尾对齐，避免 [AnimatedSize] 每帧抖窗。
final class DesktopWindowResizeCoordinator {
  DesktopWindowResizeCoordinator({
    this.minSize = const Size(260, 220),
    this.maxSize = const Size(560, 920),
  });

  final Size minSize;
  final Size maxSize;

  Size? _lastApplied;
  DateTime? _lastThrottle;
  Timer? _debounce;

  /// [content] 为待放入客户区的逻辑像素尺寸（与 [window_manager.setSize] 一致）。
  Future<void> requestSize(Size content) async {
    if (!tomatoIsDesktop) return;

    final w = content.width.clamp(minSize.width, maxSize.width);
    final h = content.height.clamp(minSize.height, maxSize.height);
    final target = Size(w, h);

    if (_lastApplied != null) {
      final p = _lastApplied!;
      if ((p.width - target.width).abs() < 1 && (p.height - target.height).abs() < 1) {
        return;
      }
    }

    final now = DateTime.now();
    void apply() {
      _lastApplied = target;
      _lastThrottle = DateTime.now();
      unawaited(windowManager.setSize(target));
    }

    if (_lastThrottle == null || now.difference(_lastThrottle!).inMilliseconds > 90) {
      apply();
    } else {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 140), apply);
    }
  }

  void dispose() {
    _debounce?.cancel();
  }
}
