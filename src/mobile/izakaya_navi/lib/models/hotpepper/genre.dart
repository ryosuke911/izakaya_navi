/// ジャンル情報のマスターデータモデル
class Genre {
  final String code;
  final String name;

  Genre({
    required this.code,
    required this.name,
  });

  /// JSONからモデルを生成
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
} 