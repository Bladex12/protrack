class Videogame {
  final int id;
  final String name;
  final String slug;

  Videogame({required this.id, required this.name, required this.slug});

  factory Videogame.fromJson(Map<String, dynamic> json) => Videogame(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
      );
}
