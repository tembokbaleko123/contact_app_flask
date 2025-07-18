class Group {
  final int? id;
  final String? name;
  final String? description;
  final int? userId; // ✅ Tambahan user_id

  Group({
    this.id,
    this.name,
    this.description,
    this.userId,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userId: json['user_id'], // ✅ Ambil dari JSON jika tersedia
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'user_id': userId, // ✅ Kirim ke backend
    };
  }
}
