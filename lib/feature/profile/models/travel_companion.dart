class TravelCompanion {
  String id;
  String nickname;
  String ageGroup;
  List<String> interests;

  TravelCompanion({
    required this.id,
    required this.nickname,
    required this.ageGroup,
    required this.interests,
  });

  factory TravelCompanion.fromJson(Map<String, dynamic> json) {
    return TravelCompanion(
      id: json['id'],
      nickname: json['nickname'],
      ageGroup: json['ageGroup'],
      interests: List<String>.from(json['interests']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'ageGroup': ageGroup,
      'interests': interests,
    };
  }

  TravelCompanion copyWith({
    String? id,
    String? nickname,
    String? ageGroup,
    List<String>? interests,
  }) {
    return TravelCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      ageGroup: ageGroup ?? this.ageGroup,
      interests: interests ?? this.interests,
    );
  }
}

// 年齡層選項
class AgeGroups {
  static const List<String> values = [
    '0-3歲',
    '3-6歲',
    '6-12歲',
    '12-18歲',
    '18-30歲',
    '40代',
    '50代',
    '60代',
    '70代',
    '80以上'
  ];
}
