class Area {
  final String code;
  final String name;
  final Map<String, dynamic>? largeArea;
  final Map<String, dynamic>? middleArea;
  final Map<String, dynamic>? smallArea;

  Area({
    required this.code,
    required this.name,
    this.largeArea,
    this.middleArea,
    this.smallArea,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      code: json['code'],
      name: json['name'],
      largeArea: json['large_area'],
      middleArea: json['middle_area'],
      smallArea: json['small_area'],
    );
  }
} 