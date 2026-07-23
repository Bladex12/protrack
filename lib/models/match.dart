import 'opponent.dart';

class Match {
  final int id;
  final DateTime? beginAt;
  final String videogameName;
  final String status;
  final List<Opponent> opponents;

  Match({
    required this.id,
    this.beginAt,
    required this.videogameName,
    required this.status,
    required this.opponents,
  });

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'],
        beginAt:
            json['begin_at'] != null ? DateTime.tryParse(json['begin_at']) : null,
        videogameName: json['videogame']?['name'] ?? '',
        status: json['status'] ?? 'not_started',
        opponents: (json['opponents'] as List? ?? [])
            .map((o) => Opponent.fromJson(o['opponent'] as Map<String, dynamic>))
            .toList(),
      );

  String get title => opponents.length >= 2
      ? '${opponents[0].name} vs ${opponents[1].name}'
      : (opponents.isNotEmpty ? opponents[0].name : 'TBD');
}
