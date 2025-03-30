class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final int lastSynced;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.lastSynced,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'lastSynced': lastSynced,
    };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      location: map['location'],
      lastSynced: map['lastSynced'],
    );
  }
}