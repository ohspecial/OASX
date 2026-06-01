part of 'script_log_browser_controller.dart';

/// Maximum lines kept when jumping back to live bottom.
const int _liveFollowLineLimit = 800;

/// Cursor schema used by the log browser API.
const int _logCursorVersion = 1;

extension ScriptLogBrowserInfoX on ScriptLogBrowserController {
  /// Loads latest log window and starts live stream.
  Future<void> refreshLatest() async {
    final requestId = ++revision;
    _infoLoadRequestId = requestId;
    infoLoading.value = true;
    infoError.value = '';
    await stopStream();
    try {
      final window = await ApiClient().getScriptLogWindow(scriptName);
      if (!isInfoLoadActive(requestId)) {
        return;
      }
      applyFreshWindow(window);
      infoLoading.value = false;
      unawaited(startStream(requestId));
      syncBottomAfterFrame();
    } catch (error) {
      if (!isInfoLoadActive(requestId)) {
        return;
      }
      infoLoading.value = false;
      infoError.value = error.toString();
      streamStatus.value = ScriptLogStreamStatus.error;
    } finally {
      if (_infoLoadRequestId == requestId) {
        _infoLoadRequestId = 0;
      }
    }
  }

  /// Loads older lines before the current first line.
  Future<void> prefetchOlder() async {
    final cursor = olderCursor;
    if (cursor == null || cursor.isEmpty || reachedStart) {
      return;
    }
    if (olderLoading.value || infoLoading.value) {
      return;
    }
    final requestId = revision;
    _olderLoadRequestId = requestId;
    olderLoading.value = true;
    try {
      final window = await ApiClient().getScriptLogWindow(
        scriptName,
        cursor: cursor,
      );
      if (isOlderLoadActive(requestId)) {
        prependOlderWindow(window);
      }
    } catch (error) {
      if (isOlderLoadActive(requestId)) {
        infoError.value = error.toString();
      }
    } finally {
      if (isOlderLoadActive(requestId)) {
        olderLoading.value = false;
      }
      if (_olderLoadRequestId == requestId) {
        _olderLoadRequestId = 0;
      }
    }
  }

  /// Clears currently displayed info lines.
  void clearInfoLogs() {
    lines.clear();
    _lineKeys.clear();
    maxLineWidthScore = 0;
    savedScrollOffset = 0;
    savedAnchorKey = '';
    savedAnchorDelta = 0;
  }

  /// Copies info lines to clipboard.
  void copyInfoLogs() {
    copyText(lines.map((line) => line.text).join('\n'));
  }

  /// Releases excessive history before returning to live tail.
  void trimToLiveWindow() {
    if (lines.length <= _liveFollowLineLimit) {
      return;
    }
    final removedCount = lines.length - _liveFollowLineLimit;
    final removedLines = lines.take(removedCount).toList();
    lines.removeRange(0, removedCount);
    for (final line in removedLines) {
      _lineKeys.remove(line.key);
    }
    if (lines.isNotEmpty) {
      olderCursor = _buildOlderCursor(lines.first);
      reachedStart = false;
    }
    _recomputeMaxLineWidthScore();
  }

  /// Starts the live stream without replacing the current visible window.
  Future<void> resumeLiveStream() async {
    final requestId = ++revision;
    await stopStream();
    unawaited(startStream(requestId));
  }

  /// Applies a fresh latest window.
  void applyFreshWindow(ScriptLogWindow window) {
    lines.assignAll(window.lines);
    _lineKeys
      ..clear()
      ..addAll(window.lines.map((line) => line.key));
    _recomputeMaxLineWidthScore();
    olderCursor = window.olderCursor;
    liveCursor = window.liveCursor;
    reachedStart = window.reachedStart || !window.hasOlder;
  }

  /// Prepends older lines and asks UI to preserve viewport.
  void prependOlderWindow(ScriptLogWindow window) {
    if (window.lines.isEmpty) {
      olderCursor = window.olderCursor;
      reachedStart = window.reachedStart || !window.hasOlder;
      return;
    }
    final olderLines = window.lines
        .where((line) => !_lineKeys.contains(line.key))
        .toList();
    if (olderLines.isNotEmpty) {
      lines.insertAll(0, olderLines);
      _lineKeys.addAll(olderLines.map((line) => line.key));
      _recomputeMaxLineWidthScore();
      preserveViewportAfterPrepend?.call(olderLines.length);
    }
    olderCursor = window.olderCursor;
    reachedStart = window.reachedStart || !window.hasOlder;
  }

  /// Recomputes the widest line score after bulk changes.
  void _recomputeMaxLineWidthScore() {
    maxLineWidthScore = 0;
    for (final line in lines) {
      final score = _scoreScriptLogLineWidth(line.text);
      if (score > maxLineWidthScore) {
        maxLineWidthScore = score;
      }
    }
  }

  /// Restores the saved manual position.
  void restoreManualPosition() {
    if (savedScrollOffset <= 0) {
      return;
    }
    restoreScrollOffset?.call(savedScrollOffset);
  }

  /// Schedules a bottom follow after the current frame.
  void syncBottomAfterFrame() {
    if (_bottomSyncQueued) {
      return;
    }
    _bottomSyncQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bottomSyncQueued = false;
      scrollToBottom?.call();
    });
  }

  /// Builds an API-compatible older cursor for a retained first line.
  String _buildOlderCursor(ScriptLogLine line) {
    final cursorPayload = {
      'v': _logCursorVersion,
      'script_name': scriptName,
      'direction': 'older',
      'file_name': line.fileName,
      'offset': line.offset,
      'line_no': line.lineNo,
    };
    final json = jsonEncode(cursorPayload);
    return base64Url.encode(utf8.encode(json)).replaceAll('=', '');
  }
}
