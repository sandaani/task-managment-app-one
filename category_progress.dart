class CategoryProgress {
  final String userId;
  final String category;
  final int totalTasks;
  final int completedTasks;

  CategoryProgress({
    required this.userId,
    required this.category,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;

  factory CategoryProgress.fromJson(Map<String, dynamic> json) {
    return CategoryProgress(
      userId: json['userId'] as String,
      category: json['category'] as String,
      totalTasks: json['totalTasks'] as int,
      completedTasks: json['completedTasks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'category': category,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
    };
  }

  CategoryProgress copyWith({
    String? userId,
    String? category,
    int? totalTasks,
    int? completedTasks,
  }) {
    return CategoryProgress(
      userId: userId ?? this.userId,
      category: category ?? this.category,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}
