import 'package:flutter/foundation.dart';

import '../../models/profile.dart';
import '../../services/auth_service.dart';
import '../../services/discovery_service.dart';

class MatchEvent {
  final DiscoveryCandidate candidate;
  final String? conversationId;

  const MatchEvent(this.candidate, this.conversationId);
}

class DiscoveryProvider extends ChangeNotifier {
  DiscoveryProvider({required DiscoveryService service}) : _service = service;

  final DiscoveryService _service;
  final List<DiscoveryCandidate> _queue = [];
  final Set<String> _seen = {};
  bool _isLoading = false;
  bool _hasMore = true;
  bool _disposed = false;
  String? _error;
  String? _notice;
  MatchEvent? _pendingMatch;

  List<DiscoveryCandidate> get queue => List.unmodifiable(_queue);
  bool get isLoading => _isLoading;
  bool get needsSignIn => !_service.hasSession;
  String? get error => _error;
  MatchEvent? get pendingMatch => _pendingMatch;
  String? get notice => _notice;

  Future<void> loadInitial() async {
    _queue.clear();
    _seen.clear();
    _hasMore = true;
    _error = null;
    await _loadMore();
  }

  /// The server excludes profiles already reacted to, so the next page starts
  /// after the unreacted cards still waiting in the deck.
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || needsSignIn) {
      _notify();
      return;
    }
    _isLoading = true;
    _error = null;
    _notify();
    try {
      final page = await _service.loadPage(offset: _queue.length);
      final fresh = page.where((c) => _seen.add(c.profile.id)).toList();
      if (fresh.isEmpty) _hasMore = false;
      _queue.addAll(fresh);
    } catch (e) {
      _error = 'No pudimos cargar perfiles. ${AuthService.messageFor(e)}';
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  DiscoveryCandidate? byId(String id) {
    for (final c in _queue) {
      if (c.profile.id == id) return c;
    }
    return null;
  }

  Future<void> decide(SwipeDecision decision, {String? profileId}) async {
    final index = profileId == null ? (_queue.isEmpty ? -1 : 0) : _queue.indexWhere((c) => c.profile.id == profileId);
    if (index < 0) return;
    final candidate = _queue.removeAt(index);
    _notify();
    try {
      final result = await _service.react(candidate.profile.id, decision);
      if (result.matched) {
        _pendingMatch = MatchEvent(candidate, result.conversationId);
        _notify();
      }
    } catch (e) {
      // The server did not record the reaction, so the person returns to the deck.
      _queue.insert(index.clamp(0, _queue.length), candidate);
      _notice = 'No pudimos guardar tu decisión. ${AuthService.messageFor(e)}';
      _notify();
    }
    if (_queue.length < 3) await _loadMore();
  }

  /// One-shot UI events; cleared without notifying to avoid rebuild loops.
  MatchEvent? takeMatch() {
    final m = _pendingMatch;
    _pendingMatch = null;
    return m;
  }

  String? takeNotice() {
    final n = _notice;
    _notice = null;
    return n;
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
