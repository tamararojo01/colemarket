import 'package:flutter/foundation.dart';

enum Condition { likeNew, good, fair }

const conditionLabels = {
  Condition.likeNew: 'Como nuevo',
  Condition.good: 'Bueno',
  Condition.fair: 'Aceptable',
};

class AppUser {
  final String id;
  final String? email;
  final String? phone;
  final String? address;
  final String defaultSchoolId;

  AppUser({
    required this.id,
    this.email,
    this.phone,
    this.address,
    required this.defaultSchoolId,
  });

  AppUser copyWith({String? email, String? phone, String? address}) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      defaultSchoolId: defaultSchoolId,
    );
  }
}

class School {
  final String id;
  final String name;
  final List<Garment> garments;
  School({required this.id, required this.name, required this.garments});
}

class Garment {
  final String id;
  final String label;
  final List<String> sizes;
  Garment({required this.id, required this.label, required this.sizes});
}

class Listing {
  final String id;
  final String userId;
  final String schoolId;
  final String garmentId;
  final String title;
  final String size;
  final double price;
  final Condition condition;
  final List<String> defects;
  final bool active;
  final bool isFavorite;

  Listing({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.garmentId,
    required this.title,
    required this.size,
    required this.price,
    required this.condition,
    required this.defects,
    required this.active,
    required this.isFavorite,
  });

  Listing copyWith({
    String? id,
    String? userId,
    String? schoolId,
    String? garmentId,
    String? title,
    String? size,
    double? price,
    Condition? condition,
    List<String>? defects,
    bool? active,
    bool? isFavorite,
  }) {
    return Listing(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      schoolId: schoolId ?? this.schoolId,
      garmentId: garmentId ?? this.garmentId,
      title: title ?? this.title,
      size: size ?? this.size,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      defects: defects ?? this.defects,
      active: active ?? this.active,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Listing.sample({
    required String title,
    required String schoolId,
    required String garmentId,
    required String size,
    required double price,
    required Condition condition,
    List<String> defects = const [],
  }) {
    return Listing(
      id: UniqueKey().toString(),
      userId: 'u1',
      schoolId: schoolId,
      garmentId: garmentId,
      title: title,
      size: size,
      price: price,
      condition: condition,
      defects: defects,
      active: true,
      isFavorite: false,
    );
    }
}

class Conversation {
  final String id;
  final String otherUserName;
  final String lastMessage;
  Conversation({required this.id, required this.otherUserName, required this.lastMessage});
}
