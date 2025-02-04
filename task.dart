class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final bool isCompleted;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.status = 'upcoming',
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String? ?? 'upcoming',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'isCompleted': isCompleted,
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
