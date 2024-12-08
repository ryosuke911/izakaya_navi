import '../venue.dart';
import '../location.dart';
import 'area.dart';

class Shop {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? access;
  final String? openTime;
  final String? closeTime;
  final List<String> photos;
  final List<String> genres;
  final String? budget;
  final String? capacity;
  final String? privateRoom;
  final String? smoking;
  final String? freeDrink;
  final Map<String, dynamic> rawJson;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.access,
    this.openTime,
    this.closeTime,
    required this.photos,
    required this.genres,
    this.budget,
    this.capacity,
    this.privateRoom,
    this.smoking,
    this.freeDrink,
    required this.rawJson,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    final photo = json['photo'] as Map<String, dynamic>?;
    final photoUrls = <String>[];
    if (photo != null && photo['mobile'] != null) {
      final mobile = photo['mobile'] as Map<String, dynamic>;
      if (mobile['l'] != null) {
        final photoUrl = mobile['l'] as String;
        final convertedUrl = photoUrl.replaceFirst('https://160.17.98.51', 'https://imgfp.hotp.jp');
        photoUrls.add(convertedUrl);
      }
    }

    final genre = json['genre'] as Map<String, dynamic>?;
    final genreNames = <String>[];
    if (genre != null && genre['name'] != null) {
      genreNames.add(genre['name'] as String);
    }

    final budget = json['budget'] as Map<String, dynamic>?;
    final budgetName = budget?['name'] as String?;

    final lat = (json['lat'] is String) 
        ? double.parse(json['lat'] as String) 
        : json['lat'] as double;
    final lng = (json['lng'] is String) 
        ? double.parse(json['lng'] as String) 
        : json['lng'] as double;

    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: lat,
      lng: lng,
      access: json['access'] as String?,
      openTime: json['open'] as String?,
      closeTime: json['close'] as String?,
      photos: photoUrls,
      genres: genreNames,
      budget: budgetName,
      capacity: json['party_capacity']?.toString(),
      privateRoom: json['private_room']?.toString(),
      smoking: json['smoking']?.toString(),
      freeDrink: json['free_drink']?.toString(),
      rawJson: json,
    );
  }

  static List<Shop> listFromJson(List<dynamic> json) {
    return json.map((data) => Shop.fromJson(data as Map<String, dynamic>)).toList();
  }

  Venue toVenue() {
    return Venue(
      id: id,
      name: name,
      location: Location(
        latitude: lat,
        longitude: lng,
      ),
      genres: genres,
      budget: budget,
      access: access,
      open: openTime,
      close: closeTime,
      photos: photos,
      address: address,
      area: rawJson['middle_area'] != null ? MiddleArea.fromJson(rawJson['middle_area'] as Map<String, dynamic>) : null,
      additionalDetails: {
        ...rawJson,
        if (capacity != null) 'party_capacity': capacity,
        if (privateRoom != null) 'private_room': privateRoom,
        if (smoking != null) 'smoking': smoking,
        if (freeDrink != null) 'free_drink': freeDrink,
      },
    );
  }
} 