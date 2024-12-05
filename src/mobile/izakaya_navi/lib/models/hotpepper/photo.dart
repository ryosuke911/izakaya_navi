class Photo {
  final Map<String, String> pc;
  final Map<String, String> mobile;

  Photo({
    required this.pc,
    required this.mobile,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      pc: Map<String, String>.from(json['pc'] ?? {}),
      mobile: Map<String, String>.from(json['mobile'] ?? {}),
    );
  }

  String? get largeImageUrl => pc['l'];
  String? get mediumImageUrl => pc['m'];
  String? get smallImageUrl => pc['s'];
} 