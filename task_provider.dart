import 'package:flutter/foundation.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/models/category_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  Map<String, CategoryProgress> _categoryProgress = {};
  String? _currentUserId;

  List<Task> get tasks {
    if (_currentUserId == null) return [];
    return _tasks.where((task) => task.userId == _currentUserId).toList();
  }

  TaskProvider() {
    loadTasks();
    loadCategoryProgress();
  }

  void setCurrentUser(String? userId) async {
    _currentUserId = userId;
    if (userId == null) {
      _tasks = [];
      _categoryProgress = {};
    } else {
      await loadTasks();
      await loadCategoryProgress();
    }
    notifyListeners();
  }

  String _getUserTaskKey(String userId) {
    return 'user_tasks_$userId';
  }

  String _getCategoryProgressKey(String userId) {
    return 'category_progress_$userId';
  }

  String _generateTaskId() {
    return '${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> loadTasks() async {
    if (_currentUserId == null) {
      _tasks = [];
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserTaskKey(_currentUserId!);
      final tasksJson = prefs.getStringList(key);

      if (tasksJson != null) {
        _tasks =
            tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> saveTasks() async {
    if (_currentUserId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getUserTaskKey(_currentUserId!);
      final tasksJson =
          _tasks.map((task) => jsonEncode(task.toJson())).toList();
      await prefs.setStringList(key, tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (_currentUserId == null) return;

    final task = Task(
      id: _generateTaskId(),
      userId: _currentUserId!,
      title: title,
      description: description,
      category: category,
      startTime: startTime,
      endTime: endTime,
    );

    _tasks.add(task);
    await saveTasks();
    await updateCategoryProgress();
    notifyListeners();
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
    required String category,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final oldTask = _tasks[index];
    final newTask = Task(
      id: taskId,
      userId: oldTask.userId,
      title: title,
      description: description,
      category: category,
      startTime: startTime,
      endTime: endTime,
      isCompleted: oldTask.isCompleted,
      status: oldTask.status,
    );

    _tasks[index] = newTask;
    await saveTasks();
    await updateCategoryProgress();
    notifyListeners();
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final oldTask = _tasks[index];
    final newTask = Task(
      id: taskId,
      userId: oldTask.userId,
      title: oldTask.title,
      description: oldTask.description,
      category: oldTask.category,
      startTime: oldTask.startTime,
      endTime: oldTask.endTime,
      isCompleted: isCompleted,
      status: isCompleted ? 'completed' : 'upcoming',
    );

    _tasks[index] = newTask;
    await saveTasks();
    await updateCategoryProgress();
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await saveTasks();
    await updateCategoryProgress();
    notifyListeners();
  }

  Future<void> loadCategoryProgress() async {
    if (_currentUserId == null) {
      _categoryProgress = {};
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCategoryProgressKey(_currentUserId!);
      final progressJson = prefs.getString(key);

      if (progressJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(progressJson);
        _categoryProgress = {
          for (var entry in decoded.entries)
            entry.key: CategoryProgress.fromJson(entry.value)
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading category progress: $e');
    }
  }

  Future<void> updateCategoryProgress() async {
    if (_currentUserId == null) return;

    final userTasks = tasks;
    final categories = userTasks.map((t) => t.category).toSet();

    _categoryProgress = {
      for (var category in categories)
        category: CategoryProgress(
          userId: _currentUserId!,
          category: category,
          totalTasks: userTasks.where((t) => t.category == category).length,
          completedTasks: userTasks
              .where((t) => t.category == category && t.isCompleted)
              .length,
        )
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCategoryProgressKey(_currentUserId!);
      final progressJson = jsonEncode({
        for (var entry in _categoryProgress.entries)
          entry.key: entry.value.toJson()
      });
      await prefs.setString(key, progressJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving category progress: $e');
    }
  }

  Map<String, CategoryProgress> get categoryProgress => _categoryProgress;

  double get completionRate {
    if (tasks.isEmpty) return 0;
    return tasks.where((task) => task.isCompleted).length / tasks.length;
  }

  List<Task> getAllTasks() {
    return _tasks;
  }

  void restoreTask(Task task) {
    _tasks.add(task);
    saveTasks();
    notifyListeners();
  }

  double calculateProductivityScore() {
    if (tasks.isEmpty) return 0;

    double score = 0;
    final now = DateTime.now();

    // Completion rate (40%)
    final completionRate =
        tasks.where((t) => t.isCompleted).length / tasks.length;
    score += completionRate * 40;

    // On-time completion (30%)
    final onTimeCompletions =
        tasks.where((t) => t.isCompleted && t.endTime.isAfter(now)).length;
    if (tasks.isNotEmpty) {
      score += (onTimeCompletions / tasks.length) * 30;
    }

    // Category balance (30%)
    final categories = tasks.map((t) => t.category).toSet();
    final categoryBalance = categories.length / max(1, tasks.length);
    score += categoryBalance * 30;

    return score;
  }

  List<FlSpot> getCompletionTrendData() {
    final spots = <FlSpot>[];
    final now = DateTime.now();

    // Get completion data for last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayTasks = tasks.where((t) => isSameDay(t.endTime, date)).toList();

      double completionRate = 0;
      if (dayTasks.isNotEmpty) {
        completionRate =
            dayTasks.where((t) => t.isCompleted).length / dayTasks.length;
      }

      spots.add(FlSpot(6 - i.toDouble(), completionRate));
    }

    return spots;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
