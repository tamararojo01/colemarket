import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum Condition { newItem, likeNew, good, used }

const conditionLabels = {
  Condition.newItem: 'Nuevo',
  Condition.likeNew: 'Como nuevo',
  Condition.good: 'Bueno',
  Condition.used: 'Con uso',
};

class Garment {
  final String id;
  final String label;
  final List<String> sizes;
  Garment({required this.id, required this.label, required this.sizes});
}

class School {
  final String id;
  final String name;
  final String city;
  final List<Garment> garments;
  School({required this.id, required this.name, required this.city, required this.garments});
}

class Listing {
  final String id;
  final String title;
  final String schoolId;
  final String garmentId;
  final String size;
  final Condition condition;
  final List<String> defects;
  final String? extraInfo;
  final double price;
  final double recommendedPrice;
  final List<String> photoUrls;
  final String userId;
  final int createdAtMs;
  bool active;
  bool isFavorite;

  Listing({
    required this.id,
    required this.title,
    required this.schoolId,
    required this.garmentId,
    required this.size,
    required this.condition,
    required this.defects,
    required this.extraInfo,
    required this.price,
    required this.recommendedPrice,
    required this.photoUrls,
    required this.userId,
    required this.createdAtMs,
    this.active = true,
    this.isFavorite = false,
  });

  factory Listing.sample({
    required String title,
    required String schoolId,
    required String garmentId,
    required String size,
    required double price,
    Condition condition = Condition.good,
    List<String> defects = const [],
  }) {
    return Listing(
      id: _uuid.v4(),
      title: title,
      schoolId: schoolId,
      garmentId: garmentId,
      size: size,
      condition: condition,
      defects: defects,
      extraInfo: null,
      price: price,
      recommendedPrice: price,
      photoUrls: const [],
      userId: 'demo',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Listing copyWith({
    String? id,
    String? title,
    String? schoolId,
    String? garmentId,
    String? size,
    Condition? condition,
    List<String>? defects,
    String? extraInfo,
    double? price,
    double? recommendedPrice,
    List<String>? photoUrls,
    String? userId,
    int? createdAtMs,
    bool? active,
    bool? isFavorite,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      schoolId: schoolId ?? this.schoolId,
      garmentId: garmentId ?? this.garmentId,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      defects: defects ?? this.defects,
      extraInfo: extraInfo ?? this.extraInfo,
      price: price ?? this.price,
      recommendedPrice: recommendedPrice ?? this.recommendedPrice,
      photoUrls: photoUrls ?? this.photoUrls,
      userId: userId ?? this.userId,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      active: active ?? this.active,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Conversation {
  final String id;
  final String otherUserName;
  final String lastMessage;
  final int timestampMs;
  Conversation({required this.id, required this.otherUserName, required this.lastMessage, required this.timestampMs});
}

class AppUser {
  final String id;
  final String? email;
  final String? phone;
  final String? address;
  final String defaultSchoolId;
  final bool plusActive;
  AppUser({
    required this.id,
    this.email,
    this.phone,
    this.address,
    required this.defaultSchoolId,
    this.plusActive = false,
  });

  AppUser copyWith({String? email, String? phone, String? address, String? defaultSchoolId, bool? plusActive}) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      defaultSchoolId: defaultSchoolId ?? this.defaultSchoolId,
      plusActive: plusActive ?? this.plusActive,
    );
  }
}
