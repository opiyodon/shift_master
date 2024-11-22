class Employee {
  final String id;
  final String name;
  final String email;
  final String? department;
  final String? position;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.department,
    this.position,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      department: map['department'],
      position: map['position'],
    );
  }
}
