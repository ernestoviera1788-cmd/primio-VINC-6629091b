import 'dart:convert';
import 'dart:typed_data';

import '../models/my_photo.dart';
import '../models/my_profile.dart';
import '../repositories/me_repository.dart';

class MeService {
  static const maxPhotos = 6;
  static const maxPhotoBytes = 10 * 1024 * 1024;

  final MeRepository repository;

  MeService({required this.repository});

  bool get hasSession => repository.hasSession;

  Future<MyProfile> load() => repository.getMe();

  Future<MyProfile> save(MyProfile profile) => repository.updateProfile(profile);

  Future<List<MyPhoto>> photos() async =>
      (await repository.listPhotos())..sort((a, b) => a.position.compareTo(b.position));

  Future<MyPhoto> upload(Uint8List bytes, String name, String mimeType) =>
      repository.uploadPhoto(name: name, mimeType: mimeType, dataBase64: base64Encode(bytes));

  Future<void> delete(String id) => repository.deletePhoto(id);

  Future<void> setPrimary(String id) => repository.setPrimaryPhoto(id);

  Future<void> reorder(List<String> ids) => repository.reorderPhotos(ids);

  /// Mirrors updateprofile's rules so mistakes are caught before the call.
  static String? validate(MyProfile p) {
    if (p.firstName.trim().isEmpty) return 'Escribe tu nombre.';
    if (p.city.trim().isEmpty || p.country.trim().isEmpty) return 'Indica tu ciudad y tu país.';
    if (p.gender.isEmpty || p.intention.isEmpty || p.preferredGender.isEmpty) {
      return 'Completa tu género, qué buscas y a quién quieres conocer.';
    }
    if (p.ageMin < 18 || p.ageMax > 99 || p.ageMin > p.ageMax) {
      return 'El rango de edad debe estar entre 18 y 99 años.';
    }
    if (p.distanceMax < 1 || p.distanceMax > 500) return 'La distancia debe estar entre 1 y 500.';
    return null;
  }

  /// The server accepts only JPEG and PNG.
  static String? mimeFor(String name, String? reported) {
    final m = reported?.toLowerCase();
    if (m == 'image/jpeg' || m == 'image/png') return m;
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return null;
  }

  static String? checkPhoto({required int sizeBytes, required String? mimeType, required int currentCount}) {
    if (currentCount >= maxPhotos) return 'Ya tienes $maxPhotos fotos. Elimina una para subir otra.';
    if (mimeType == null) return 'Solo se admiten fotos JPG o PNG.';
    if (sizeBytes > maxPhotoBytes) return 'La foto supera los 10 MB.';
    return null;
  }
}
