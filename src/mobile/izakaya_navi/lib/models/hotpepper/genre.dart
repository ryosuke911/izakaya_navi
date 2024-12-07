/// ホットペッパーAPIの�ャンルマスターデータモデル
class Genre {
  final String code;
  final String name;

  const Genre({
    required this.code,
    required this.name,
  });

  /// 居酒屋ジャンル（アプリ内で使用するメインジャンル）
  static const IZAKAYA = Genre(
    code: 'G001',
    name: '居酒屋',
  );

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Genre &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name;

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => 'Genre(code: $code, name: $name)';
} 