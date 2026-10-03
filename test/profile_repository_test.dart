import 'package:flutter_test/flutter_test.dart';
import 'package:primio_app/models/my_profile.dart';
import 'package:primio_app/repositories/api_client.dart';
import 'package:primio_app/repositories/match_repository.dart';
import 'package:primio_app/repositories/profile_repository.dart';
import 'package:primio_app/services/me_service.dart';

void main() {
  test('listdiscovery users are parsed with the primary photo first', () {
    final page = ProfileRepository.parsePage({
      'users': [
        {
          'id': 'u1',
          'firstName': 'Ana',
          'age': 30,
          'city': 'Austin',
          'bio': 'Hola',
          'photos': [
            {'id': 'a', 'url': '/p/2.jpg', 'isPrimary': false},
            {'id': 'b', 'url': 'data:;base64,AAAA', 'isPrimary': true},
          ],
        },
      ],
      'total': 1,
    });
    final p = page.profiles.single;
    expect(p.city, 'Austin');
    expect(p.photos.first, 'data:;base64,AAAA');
    expect(p.photos.last, '${ApiClient.baseUrl}/p/2.jpg');
    expect(page.total, 1);
  });

  test('listdiscovery without users fails visibly', () {
    expect(() => ProfileRepository.parsePage({'foo': 1}), throwsA(isA<ApiException>()));
  });

  test('reacttoprofile match carries the conversation', () {
    final r = ProfileRepository.parseReaction({'ok': true, 'matched': true, 'matchId': 'm1', 'conversationId': 'c1'});
    expect(r.matched, isTrue);
    expect(r.conversationId, 'c1');
  });

  test('listmatches is parsed with last message', () {
    final matches = MatchRepository.parseMatches({
      'matches': [
        {
          'matchId': 'm1',
          'conversationId': 'c1',
          'createdAt': '2026-10-01T10:00:00.000Z',
          'user': {'id': 'u1', 'firstName': 'Ana', 'age': 30},
          'lastMessage': {'body': 'Hola', 'createdAt': '2026-10-02T10:00:00.000Z', 'mine': true},
        },
      ],
    });
    expect(matches.single.lastMessage?.body, 'Hola');
  });

  test('getme preferences are read from settings when not top-level', () {
    final p = MyProfile.fromJson({'firstName': 'Ana', 'settings': {'ageMin': 25, 'ageMax': 40, 'distanceMax': 30}});
    expect(p.ageMin, 25);
    expect(p.distanceMax, 30);
  });

  test('photo checks mirror server limits', () {
    expect(MeService.mimeFor('a.PNG', null), 'image/png');
    expect(MeService.mimeFor('a.heic', 'image/heic'), isNull);
    expect(MeService.checkPhoto(sizeBytes: 1, mimeType: 'image/jpeg', currentCount: 6), isNotNull);
    expect(MeService.checkPhoto(sizeBytes: 11 * 1024 * 1024, mimeType: 'image/jpeg', currentCount: 0), isNotNull);
    expect(MeService.checkPhoto(sizeBytes: 1, mimeType: 'image/jpeg', currentCount: 0), isNull);
  });
}
