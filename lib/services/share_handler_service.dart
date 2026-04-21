import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Boshqa ilovadan "Share" qilingan matnni qabul qilish servisi.
///
/// Android `intent-filter` (ACTION_SEND, text/plain) orqali Yozu tanlanganda
/// matn `textStream` ga kelib tushadi. `ConverterScreen` `initState`'da
/// subscribe bo'ladi.
class ShareHandlerService {
  ShareHandlerService._();
  static final ShareHandlerService instance = ShareHandlerService._();

  final _textController = StreamController<String>.broadcast();
  StreamSubscription<List<SharedMediaFile>>? _subscription;
  bool _initialized = false;

  /// Share qilingan matn oqimi.
  Stream<String> get textStream => _textController.stream;

  /// App boshlanganda chaqiriladi.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // Ilova ochiq paytda kelgan share
      _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
        _handleSharedFiles,
        onError: (Object e) => debugPrint('ShareHandler stream error: $e'),
      );

      // Ilova yopiq paytda ochilgan bo'lsa, oldin kelgan share'ni olish
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      if (initial.isNotEmpty) {
        _handleSharedFiles(initial);
        ReceiveSharingIntent.instance.reset();
      }
    } catch (e) {
      debugPrint('ShareHandler init error: $e');
    }
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    for (final f in files) {
      if (f.type == SharedMediaType.text || f.type == SharedMediaType.url) {
        final text = f.path.trim();
        if (text.isNotEmpty) {
          _textController.add(text);
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _textController.close();
  }
}
