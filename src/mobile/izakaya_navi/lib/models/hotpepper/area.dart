/// エリア情報のマスターデータモデル
class Area {
  final String code;
  final String name;

  Area({
    required this.code,
    required this.name,
  });

  /// JSONからモデルを生成
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Area && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
} 