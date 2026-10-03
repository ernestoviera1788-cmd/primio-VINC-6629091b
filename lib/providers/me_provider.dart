import 'package:flutter/foundation.dart';

import '../models/my_photo.dart';
import '../models/my_profile.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';
import '../services/me_service.dart';

class MeProvider extends ChangeNotifier {
  MeProvider({required MeService service}) : _service = service;

  final MeService _service;
  MyProfile? _profile;
  List<MyPhoto> _photos = const [];
  bool _loading = false;
  bool _saving = false;
  bool _photoBusy = false;
  bool _disposed = false;
  String? _error;

  MyProfile? get profile => _profile;
  List<MyPhoto> get photos => _photos;
  bool get isLoading => _loading;
  bool get isSaving => _saving;
  bool get photoBusy => _photoBusy;
  String? get error => _error;
  bool get needsSignIn => !_service.hasSession;
  int get maxPhotos => MeService.maxPhotos;
  bool get canAddPhoto => _photos.length < MeService.maxPhotos;

  /// What other people see: only approved photos, primary first.
  Profile? get publicPreview {
    final p = _profile;
    if (p == null) return null;
    final approved = _photos.where((x) => x.state == PhotoStatus.approved && x.url != null).toList()
      ..sort((a, b) => (b.isPrimary ? 1 : 0) - (a.isPrimary ? 1 : 0));
    return p.toPublic(photos: [for (final x in approved) x.url!]);
  }

  Future<void> load() async {
    if (needsSignIn) return;
    _loading = true;
    _error = null;
    _notify();
    try {
      _profile = await _service.load();
      _photos = await _service.photos();
    } catch (e) {
      _error = AuthService.messageFor(e);
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<String?> save(MyProfile updated) async {
    final invalid = MeService.validate(updated);
    if (invalid != null) return invalid;
    _saving = true;
    _notify();
    try {
      _profile = await _service.save(updated);
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
    } finally {
      _saving = false;
      _notify();
    }
  }

  Future<String?> addPhoto(Uint8List bytes, String name, String? reportedMime) async {
    final mime = MeService.mimeFor(name, reportedMime);
    final invalid = MeService.checkPhoto(sizeBytes: bytes.length, mimeType: mime, currentCount: _photos.length);
    if (invalid != null) return invalid;
    return _photoAction(() => _service.upload(bytes, name, mime!));
  }

  Future<String?> deletePhoto(String id) => _photoAction(() => _service.delete(id));

  Future<String?> setPrimary(String id) => _photoAction(() => _service.setPrimary(id));

  /// Moves a photo one place earlier (-1) or later (+1); the server needs every id.
  Future<String?> move(String id, int delta) async {
    final ids = _photos.map((p) => p.id).toList();
    final from = ids.indexOf(id);
    final to = from + delta;
    if (from < 0 || to < 0 || to >= ids.length) return null;
    ids.insert(to, ids.removeAt(from));
    return _photoAction(() => _service.reorder(ids));
  }

  Future<String?> _photoAction(Future<Object?> Function() action) async {
    _photoBusy = true;
    _notify();
    try {
      await action();
      _photos = await _service.photos();
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
    } finally {
      _photoBusy = false;
      _notify();
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
