class User {
  final int? id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phone;
  final bool isAdmin;

  User({
    this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phone,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      phone: json['phone'],
      isAdmin: json['is_admin'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'phone': phone,
      'is_admin': isAdmin ? 1 : 0,
    };
  }
}
