/// 店舗写真情報のモデル（モバイル用）
class Photo {
  final String url;
  final String? caption;

  Photo({
    required this.url,
    this.caption,
  });

  /// JSONからモデルを生成
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      url: json['mobile']['l'] as String, // モバイル用の大きいサイズの画像を使用
      caption: json['caption'] as String?,
    );
  }

  @override
  String toString() => 'Photo(url: $url, caption: $caption)';
} 