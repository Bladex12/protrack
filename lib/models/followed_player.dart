class FollowedPlayer {
  final String id;
  final int playerId;
  final String playerName;
  final String? playerImageUrl;
  final int? teamId;
  final String? teamName;

  FollowedPlayer({
    required this.id,
    required this.playerId,
    required this.playerName,
    this.playerImageUrl,
    this.teamId,
    this.teamName,
  });

  factory FollowedPlayer.fromMap(Map<String, dynamic> map) => FollowedPlayer(
        id: map['id'],
        playerId: map['player_id'],
        playerName: map['player_name'],
        playerImageUrl: map['player_image_url'],
        teamId: map['team_id'],
        teamName: map['team_name'],
      );

  Map<String, dynamic> toInsertMap(String userId) => {
        'user_id': userId,
        'player_id': playerId,
        'player_name': playerName,
        'player_image_url': playerImageUrl,
        'team_id': teamId,
        'team_name': teamName,
      };
}
