import '../models/my_photo.dart';
import '../models/my_profile.dart';
import 'api_client.dart';
import 'profile_parser.dart';

/// The signed-in user's own profile and photos.
class MeRepository {
  final ApiClient _api;
  final String? Function() _token;

  MeRepository({ApiClient? api, required String? Function() tokenProvider})
      : _api = api ?? ApiClient(),
        _token = tokenProvider;

  bool get hasSession => _token() != null;

  Future<MyProfile> getMe() async => _profile(await _api.sendAuthed('getme', _token()));

  Future<MyProfile> updateProfile(MyProfile profile) async =>
      _profile(await _api.sendAuthed('updateprofile', _token(), profile.toArgs()));

  Future<List<MyPhoto>> listPhotos() async {
    final data = await _api.sendAuthed('listmyphotos', _token());
    if (data is! List) throw ApiException('BAD_RESPONSE', 'listmyphotos: $data');
    return [
      for (final p in data)
        if (p is Map) parsePhoto(p),
    ];
  }

  Future<MyPhoto> uploadPhoto({required String name, required String mimeType, required String dataBase64}) async {
    final data = await _api.sendAuthed('uploadprofilephoto', _token(), {
      'name': name,
      'mimeType': mimeType,
      'dataBase64': dataBase64,
    });
    if (data is! Map) throw ApiException('BAD_RESPONSE', 'uploadprofilephoto: $data');
    return parsePhoto(data);
  }

  Future<void> deletePhoto(String photoId) async {
    await _api.sendAuthed('deleteprofilephoto', _token(), {'photoId': photoId});
  }

  Future<void> reorderPhotos(List<String> photoIds) async {
    await _api.sendAuthed('reorderprofilephotos', _token(), {'photoIds': photoIds});
  }

  Future<void> setPrimaryPhoto(String photoId) async {
    await _api.sendAuthed('setprimaryphoto', _token(), {'photoId': photoId});
  }

  static MyPhoto parsePhoto(Map p) => MyPhoto(
        id: '${p['id']}',
        position: p['position'] is num ? (p['position'] as num).toInt() : 0,
        isPrimary: p['isPrimary'] == true,
        url: ProfileParser.resolveUrl(p['url']),
        altText: p['altText']?.toString(),
        status: p['status']?.toString() ?? '',
      );

  static MyProfile _profile(dynamic data) {
    if (data is! Map) throw ApiException('BAD_RESPONSE', 'Perfil: $data');
    final inner = data['profile'] is Map ? data['profile'] as Map : (data['user'] is Map ? data['user'] as Map : data);
    return MyProfile.fromJson(Map<String, dynamic>.from(inner));
  }
}
