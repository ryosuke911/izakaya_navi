class Budget {
  final String code;
  final String name;
  final String? average;

  Budget({
    required this.code,
    required this.name,
    this.average,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      code: json['code'],
      name: json['name'],
      average: json['average'],
    );
  }
} 