import 'dart:convert';
import 'area.dart';
import 'genre.dart';

/// 詳細検索条件のパラメータモデル
class SearchParams {
  final String? keyword;
  final Area? area;
  final List<Genre> genres;
  final BudgetRange? budget;
  final int? partySize;
  final bool? hasPrivateRoom;
  final SmokingType? smokingType;
  final bool? hasFreedrink;
  final bool? openNow;
  final bool? lateNight;

  SearchParams({
    this.keyword,
    this.area,
    this.genres = const [],
    this.budget,
    this.partySize,
    this.hasPrivateRoom,
    this.smokingType,
    this.hasFreedrink,
    this.openNow,
    this.lateNight,
  });

  /// 検索フォームの入力値からインスタンスを生成
  factory SearchParams.fromForm({
    String? keyword,
    Area? area,
    List<Genre> genres = const [],
    int? budgetMin,
    int? budgetMax,
    int? partySize,
    bool? hasPrivateRoom,
    SmokingType? smokingType,
    bool? hasFreedrink,
    bool? openNow,
    bool? lateNight,
  }) {
    return SearchParams(
      keyword: keyword,
      area: area,
      genres: genres,
      budget: (budgetMin != null || budgetMax != null)
          ? BudgetRange(min: budgetMin, max: budgetMax)
          : null,
      partySize: partySize,
      hasPrivateRoom: hasPrivateRoom,
      smokingType: smokingType,
      hasFreedrink: hasFreedrink,
      openNow: openNow,
      lateNight: lateNight,
    );
  }

  /// APIリクエストパラメータに変換
  Map<String, dynamic> toApiParameters() {
    final params = <String, dynamic>{};

    if (keyword?.isNotEmpty ?? false) {
      params['keyword'] = keyword;
    }

    if (area != null) {
      params['small_area'] = area!.code;
    }

    if (genres.isNotEmpty) {
      params['genre'] = genres.map((g) => g.code).join(',');
    }

    if (budget != null) {
      if (budget!.min != null) {
        params['budget_from'] = budget!.min.toString();
      }
      if (budget!.max != null) {
        params['budget_to'] = budget!.max.toString();
      }
    }

    if (partySize != null && partySize! > 0) {
      params['party_capacity'] = partySize.toString();
    }

    if (hasPrivateRoom != null && hasPrivateRoom!) {
      params['private_room'] = '1';
    }

    if (smokingType != null) {
      params['smoking'] = _convertSmokingType(smokingType!);
    }

    if (hasFreedrink != null && hasFreedrink!) {
      params['free_drink'] = '1';
    }

    if (openNow != null && openNow!) {
      params['open_now'] = '1';
    }

    if (lateNight != null && lateNight!) {
      params['midnight'] = '1';
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

  @override
  String toString() {
    return jsonEncode({
      'keyword': keyword,
      'area': area?.code,
      'genres': genres.map((g) => g.code).toList(),
      'budget': budget?.toString(),
      'partySize': partySize,
      'hasPrivateRoom': hasPrivateRoom,
      'smokingType': smokingType?.toString(),
      'hasFreedrink': hasFreedrink,
      'openNow': openNow,
      'lateNight': lateNight,
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