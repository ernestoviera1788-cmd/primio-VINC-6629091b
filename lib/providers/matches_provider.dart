import 'package:flutter/foundation.dart';

import '../models/match_item.dart';
import '../services/auth_service.dart';
import '../services/match_service.dart';

class MatchesProvider extends ChangeNotifier {
  MatchesProvider({required MatchService service}) : _service = service;

  final MatchService _service;
  List<MatchItem> _matches = const [];
  bool _loading = false;
  bool _disposed = false;
  String? _error;

  List<MatchItem> get matches => _matches;
  List<MatchItem> get byActivity => [..._matches]..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  bool get isLoading => _loading;
  String? get error => _error;
  bool get needsSignIn => !_service.hasSession;

  MatchItem? byConversation(String conversationId) =>
      _matches.where((m) => m.conversationId == conversationId).firstOrNull;

  Future<void> load() async {
    if (needsSignIn) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      _matches = await _service.matches();
    } catch (e) {
      _error = AuthService.messageFor(e);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<String?> unmatch(MatchItem match) async {
    try {
      await _service.unmatch(match.matchId);
      _matches = _matches.where((m) => m.matchId != match.matchId).toList();
      _notify();
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
