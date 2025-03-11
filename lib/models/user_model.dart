class UserModel {
  final String uid;
  final String email;

  UserModel({required this.uid, required this.email});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '', // Ensure null safety
      email: data['email'] ?? '', // Ensure null safety
    );
  }
}