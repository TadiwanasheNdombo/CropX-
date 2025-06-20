import 'dart:math';

class Task {
  final String id; // Will store MongoDB ObjectId
  final String name;
  final String dueDate;
  final String description;
  final List<String> resources;
  final bool isCompleted;

  Task({
    String? id,
    required this.name,
    required this.dueDate,
    this.description = '',
    this.resources = const [],
    this.isCompleted = false,
  }) : id = id ?? _generateMongoId(); // Generate valid ID if not provided

  // Generate MongoDB-style ObjectId (24-character hex string)
  static String _generateMongoId() {
    final random = Random();
    const hexChars = '0123456789abcdef';
    return List.generate(24, (index) => hexChars[random.nextInt(16)]).join();
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? _generateMongoId(),
      name: map['name']?.toString() ?? '',
      dueDate: map['dueDate']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      resources: List<String>.from(
        map['resources']?.map((x) => x.toString()) ?? [],
      ),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.length == 24) '_id': id, // Only include if valid ObjectId
      'name': name,
      'dueDate': dueDate,
      'description': description,
      'resources': resources,
      'isCompleted': isCompleted,
    };
  }

  Task copyWith({
    String? id,
    String? name,
    String? dueDate,
    String? description,
    List<String>? resources,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      resources: resources ?? this.resources,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Helper to check if ID is valid MongoDB ObjectId format
  bool get isValidId => id.length == 24 && RegExp(r'^[a-f0-9]+$').hasMatch(id);
}
