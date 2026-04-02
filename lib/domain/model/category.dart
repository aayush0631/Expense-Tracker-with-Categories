class Catogory {
  final int id;
  final String name;

  Catogory({required this.id, required this.name});

  factory Catogory.fromMap(Map<String, dynamic> map) {
    return Catogory(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
