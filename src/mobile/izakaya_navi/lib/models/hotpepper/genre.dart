class Genre {
  final String code;
  final String name;
  final String? catch_copy;

  Genre({
    required this.code,
    required this.name,
    this.catch_copy,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      code: json['code'],
      name: json['name'],
      catch_copy: json['catch'],
    );
  }
} 