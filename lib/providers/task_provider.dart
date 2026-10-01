import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_item.dart';
import '../models/activity_log_entry.dart';
import '../database/local_database.dart';

class TaskProvider with ChangeNotifier {
  final LocalDatabase _db = LocalDatabase();

  List<TaskItem> _tasks = [];
  List<ActivityLogEntry> _logs = [];
  bool _isLoading = false;

  List<TaskItem> get tasks => _tasks;
  List<ActivityLogEntry> get logs => _logs;
  bool get isLoading => _isLoading;

  List<TaskItem> get activeTasks => _tasks.where((t) => t.status == TaskStatus.active).toList();
  List<TaskItem> get recentTasks => _tasks.take(5).toList();

  Future<void> loadTasksAndLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _db.loadTasks();
      _logs = await _db.loadActivityLogs();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<TaskItem> createTask({
    required String title,
    String targetUrl = '',
    List<String> profileSectionsUsed = const [],
    String notes = '',
  }) async {
    final task = TaskItem(
      id: const Uuid().v4(),
      title: title,
      targetUrl: targetUrl,
      status: TaskStatus.idle,
      profileSectionsUsed: profileSectionsUsed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: notes,
    );

    _tasks.insert(0, task);
    await _db.saveTasks(_tasks);

    // Log task creation
    await _db.addActivityLog(ActivityLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      actionType: 'taskCreated',
      title: 'Task Created',
      description: 'Created task: "$title"',
      targetUrl: targetUrl,
    ));

    await loadTasksAndLogs();
    return task;
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await _db.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> updateTaskCounts(String taskId, {int? detected, int? filled}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        detectedFieldsCount: detected ?? _tasks[index].detectedFieldsCount,
        filledFieldsCount: filled ?? _tasks[index].filledFieldsCount,
        updatedAt: DateTime.now(),
      );
      await _db.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _db.saveTasks(_tasks);
    notifyListeners();
  }
}
