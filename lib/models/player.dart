import 'team.dart';

class Player {
  final int id;
  final String name;
  final String? imageUrl;
  final Team? currentTeam;

  Player({
    required this.id,
    required this.name,
    this.imageUrl,
    this.currentTeam,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'],
        name: json['name'] ?? 'Unknown player',
        imageUrl: json['image_url'],
        currentTeam: json['current_team'] != null
            ? Team.fromJson(json['current_team'])
            : null,
      );
}
