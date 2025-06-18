class UserAuth {
  final String email;
  final String password;
  final String name;
  final String? travelType;

  UserAuth({
    required this.email,
    required this.password,
    required this.name,
    this.travelType,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      travelType: json['travelType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'travelType': travelType,
    };
  }
}
