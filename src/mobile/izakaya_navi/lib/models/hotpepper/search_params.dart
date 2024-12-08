import 'dart:convert';
import 'area.dart';
import 'izakaya_category.dart';

/// 詳細検索条件のパラメータモデル
class SearchParams {
  final String? keyword;
  final MiddleArea? area;
  final List<IzakayaCategory> categories;
  final BudgetRange? budget;
  final int? partySize;
  final bool? hasPrivateRoom;
  final SmokingType? smokingType;
  final bool? hasFreedrink;
  final bool? lateNight;
  final bool? openNow;
  final bool useCurrentLocation;

  const SearchParams({
    this.keyword,
    this.area,
    this.categories = const [],
    this.budget,
    this.partySize,
    this.hasPrivateRoom,
    this.smokingType,
    this.hasFreedrink,
    this.lateNight,
    this.openNow,
    this.useCurrentLocation = false,
  });

  String? get areaCode => area?.code;

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    // 常に居酒屋ジャンルを指定
    params['genre'] = 'G001';

    // カーワードとカテゴリのキーワードを組み合わせる
    final List<String> searchKeywords = [];
    
    // ユーザーが入力したキーワードがあれば追加
    if (keyword != null && keyword!.isNotEmpty) {
      searchKeywords.add(keyword!);
    }

    // カテゴリのキーワードを追加
    if (categories.isNotEmpty) {
      final categoryKeywords = categories
          .expand((category) => category.keywords)
          .join(' ');
      if (categoryKeywords.isNotEmpty) {
        searchKeywords.add(categoryKeywords);
      }
    }

    // 検索キーワードがあれば設定
    if (searchKeywords.isNotEmpty) {
      params['keyword'] = searchKeywords.join(' ');
    }

    if (area != null) {
      params['middle_area'] = area!.code;
    }

    if (budget != null) {
      if (budget!.min != null) {
        params['budget_min'] = budget!.min.toString();
      }
      if (budget!.max != null) {
        params['budget_max'] = budget!.max.toString();
      }
    }

    if (partySize != null) {
      params['party_capacity'] = partySize.toString();
    }

    if (hasPrivateRoom == true) {
      params['private_room'] = '1';
    }

    if (smokingType != null) {
      params['smoking'] = _convertSmokingType(smokingType!);
    }

    if (hasFreedrink == true) {
      params['free_drink'] = '1';
    }

    if (lateNight == true) {
      params['midnight'] = '1';
    }

    if (openNow == true) {
      params['open_now'] = '1';
    }

    return params;
  }

  String _convertSmokingType(SmokingType type) {
    switch (type) {
      case SmokingType.noSmoking:
        return '0';
      case SmokingType.smoking:
        return '1';
      case SmokingType.separatedArea:
        return '2';
    }
  }

  Map<String, String> toApiParameters() {
    return toQueryParameters();
  }

  @override
  String toString() {
    return jsonEncode({
      'keyword': keyword,
      'area': area?.code,
      'categories': categories.map((c) => c.id).toList(),
      'budget': budget?.toString(),
      'partySize': partySize,
      'hasPrivateRoom': hasPrivateRoom,
      'smokingType': smokingType?.toString(),
      'hasFreedrink': hasFreedrink,
      'openNow': openNow,
      'lateNight': lateNight,
      'useCurrentLocation': useCurrentLocation,
    });
  }
}

/// 予算範囲を表すクラス
class BudgetRange {
  final int? min;
  final int? max;

  BudgetRange({this.min, this.max});

  @override
  String toString() => 'BudgetRange(min: $min, max: $max)';
}

/// 喫煙タイプを表す列挙型
enum SmokingType {
  noSmoking,    // 禁煙
  smoking,      // 喫煙可
  separatedArea // 分煙
} 