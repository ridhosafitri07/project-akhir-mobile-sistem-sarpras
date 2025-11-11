class User {
  final int idUser;
  final String username;
  final String namaPengguna;
  final String role;
  final String? fotoProfil;
  final String? bio;
  final String? telpUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.idUser,
    required this.username,
    required this.namaPengguna,
    required this.role,
    this.fotoProfil,
    this.bio,
    this.telpUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'] ?? 0,
      username: json['username'] ?? '',
      namaPengguna: json['nama_pengguna'] ?? '',
      role: json['role'] ?? 'user',
      fotoProfil: json['foto_profil'],
      bio: json['bio'],
      telpUser: json['telp_user'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'nama_pengguna': namaPengguna,
      'role': role,
      'foto_profil': fotoProfil,
      'bio': bio,
      'telp_user': telpUser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
