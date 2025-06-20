import 'package:flutter/material.dart';
import '../../profile/models/travel_companion.dart';

class ItineraryMember {
  String id;
  String nickname;
  String ageGroup;
  List<String> interests;
  List<String> specialNeeds;

  ItineraryMember({
    required this.id,
    required this.nickname,
    required this.ageGroup,
    required this.interests,
    this.specialNeeds = const [],
  });

  // 從常用旅伴創建行程成員
  factory ItineraryMember.fromCompanion(TravelCompanion companion) {
    return ItineraryMember(
      id: companion.id,
      nickname: companion.nickname,
      ageGroup: companion.ageGroup,
      interests: companion.interests,
      specialNeeds: [],
    );
  }

  factory ItineraryMember.fromJson(Map<String, dynamic> json) {
    return ItineraryMember(
      id: json['id'],
      nickname: json['nickname'],
      ageGroup: json['ageGroup'],
      interests: List<String>.from(json['interests']),
      specialNeeds: List<String>.from(json['specialNeeds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'ageGroup': ageGroup,
      'interests': interests,
      'specialNeeds': specialNeeds,
    };
  }

  // 為每個成員生成頭像
  Widget getAvatar({double size = 50, VoidCallback? onTap}) {
    // 根據名字生成顏色
    final color = Colors.primaries[nickname.hashCode % Colors.primaries.length];
    
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: color.withOpacity(0.2),
        child: Text(
          nickname.isNotEmpty ? nickname.substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: color,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
