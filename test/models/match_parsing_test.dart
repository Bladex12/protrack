import 'package:flutter_test/flutter_test.dart';
import 'package:protracker/models/match.dart';

void main() {
  test('Match.fromJson parses opponents and title', () {
    final json = {
      'id': 123,
      'begin_at': '2026-08-01T18:00:00Z',
      'status': 'not_started',
      'videogame': {'name': 'CS2'},
      'opponents': [
        {
          'opponent': {'id': 1, 'name': 'Team A', 'image_url': null}
        },
        {
          'opponent': {'id': 2, 'name': 'Team B', 'image_url': null}
        },
      ],
    };

    final match = Match.fromJson(json);

    expect(match.id, 123);
    expect(match.videogameName, 'CS2');
    expect(match.status, 'not_started');
    expect(match.opponents.length, 2);
    expect(match.title, 'Team A vs Team B');
    expect(match.beginAt, DateTime.parse('2026-08-01T18:00:00Z'));
  });
}
