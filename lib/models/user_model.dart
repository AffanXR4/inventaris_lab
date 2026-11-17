class UserModel {
  final String userId;
  final String name;
  final String email;
  final String kelas;
  final DateTime createdAt;
  final String foto;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.kelas,
    required this.createdAt,
    this.foto = '',
  });

  // Mengubah data Firestore menjadi object UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      kelas: map['kelas'] ?? '',
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : (map['created_at'] as dynamic).toDate(),
      foto: map['foto'] ?? '',
    );
  }

  // Mengubah object UserModel menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'kelas': kelas,
      'created_at': createdAt,
      'foto': foto,
    };
  }
}
