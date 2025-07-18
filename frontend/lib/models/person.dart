class Person {
  final int? id;
  final String name;
  final String phone;
  final String imageUrl;
  int? userId;
  final int? groupId;

  Person({
    this.id,
    required this.name,
    required this.phone,
    required this.imageUrl,
    this.userId,
    this.groupId,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      imageUrl: json['image_url'] ?? '',
      userId: json['user_id'],
      groupId: json['group_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'image_url': imageUrl,
      'user_id': userId,
      'group_id': groupId,
    };
  }
}
