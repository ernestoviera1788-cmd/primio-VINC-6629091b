import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../services/auth_service.dart';
import '../services/local_notifications.dart';
import '../services/match_service.dart';

/// Route-scoped: polls listmessages every few seconds while the chat is open.
/// Newly received messages trigger a sound-bearing OS notification while the
/// app is active. Remote push is needed when this process is backgrounded/killed.
class ChatProvider extends ChangeNotifier {
  ChatProvider({required MatchService service, required this.conversationId}) : _service = service;

  static const pollInterval = Duration(seconds: 4);

  final MatchService _service;
  final String conversationId;
  List<ChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  bool _fetching = false;
  bool _disposed = false;
  bool _hasInitialMessageSnapshot = false;
  String? _error;
  Timer? _timer;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _loading;
  bool get isSending => _sending;
  String? get error => _error;

  void start() {
    refresh();
    _timer = Timer.periodic(pollInterval, (_) => refresh());
  }

  Future<void> refresh() async {
    if (_fetching || _disposed) return;
    _fetching = true;
    try {
      final latest = await _service.messages(conversationId);
      if (_hasInitialMessageSnapshot) {
        final knownIds = _messages.map((m) => m.id).toSet();
        final incoming = latest.where((m) => !m.mine && !knownIds.contains(m.id)).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        for (final message in incoming) {
          await LocalNotifications.show(
            id: message.id.hashCode,
            title: 'Nuevo mensaje en VINCÓ',
            body: message.body,
            payload: jsonEncode({'type': 'message', 'conversationId': conversationId}),
          );
        }
      }
      _messages = latest;
      _hasInitialMessageSnapshot = true;
      _error = null;
    } catch (e) {
      _error = AuthService.messageFor(e);
    } finally {
      _fetching = false;
      _loading = false;
      _notify();
    }
  }

  Future<String?> send(String text) async {
    final body = text.trim();
    if (body.isEmpty) return null;
    if (body.length > MatchService.maxMessageLength) {
      return 'El mensaje no puede superar ${MatchService.maxMessageLength} caracteres.';
    }
    _sending = true;
    _notify();
    try {
      final sent = await _service.send(conversationId, body);
      if (!_messages.any((m) => m.id == sent.id)) _messages = [..._messages, sent];
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
    } finally {
      _sending = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
