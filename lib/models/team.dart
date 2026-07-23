class Team {
  final int id;
  final String name;

  Team({required this.id, required this.name});

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'],
        name: json['name'] ?? 'Unknown team',
      );
}
