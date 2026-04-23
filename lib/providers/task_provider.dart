import 'package:flutter/material.dart';
import '../models/task_models.dart';
import '../services/task_service.dart';
import 'package:uuid/uuid.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  final _uuid = Uuid();

  List<ProjectModel> _projects = [];
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<ProjectModel> get projects => _projects;
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  void fetchProjects(String userId) {
    _taskService.getProjects(userId).listen((data) {
      _projects = data;
      notifyListeners();
    });
  }

  void fetchTasks(String projectId) {
    _taskService.getTasks(projectId).listen((data) {
      _tasks = data;
      notifyListeners();
    });
  }

  Future<void> addProject(String name, String description, String ownerId) async {
    final project = ProjectModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      ownerId: ownerId,
      memberIds: [ownerId],
      createdAt: DateTime.now(),
    );
    await _taskService.createProject(project);
  }

  Future<void> addTask({
    required String title,
    required String description,
    required String projectId,
    required String assignedToId,
    required DateTime dueDate,
  }) async {
    final task = TaskModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      projectId: projectId,
      assignedToId: assignedToId,
      status: TaskStatus.todo,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    await _taskService.createTask(task);
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _taskService.updateTaskStatus(taskId, status);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
  }
}
