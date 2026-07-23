class Opponent {
  final int id;
  final String name;
  final String? imageUrl;

  Opponent({required this.id, required this.name, this.imageUrl});

  factory Opponent.fromJson(Map<String, dynamic> json) => Opponent(
        id: json['id'],
        name: json['name'] ?? 'TBD',
        imageUrl: json['image_url'],
      );
}
