import 'package:freezed_annotation/freezed_annotation.dart';

part 'area.g.dart';
part 'area.freezed.dart';

@freezed
class MiddleArea with _$MiddleArea {
  const factory MiddleArea({
    required String code,
    required String name,
  }) = _MiddleArea;

  factory MiddleArea.fromJson(Map<String, dynamic> json) => _$MiddleAreaFromJson(json);
}

/// 中エリアのリストを管理し、ローカル検索機能を提供するクラス
class MiddleAreaList {
  final List<MiddleArea> areas;

  MiddleAreaList(List<MiddleArea> sourceAreas) : areas = sourceAreas;

  /// 入力文字列に基づいて中エリアを検索する
  /// 入力された文字列と完全一致するエリアを検索
  List<MiddleArea> search(String query) {
    if (query.isEmpty) return [];
    
    return areas.where((area) => 
      area.name.contains(query)
    ).toList();
  }
}