import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_models.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- PROJECTS ---

  Stream<List<ProjectModel>> getProjects(String userId) {
    return _db
        .collection('projects')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProjectModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> createProject(ProjectModel project) async {
    await _db.collection('projects').doc(project.id).set(project.toMap());
  }

  // --- TASKS ---

  Stream<List<TaskModel>> getTasks(String projectId) {
    return _db
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> createTask(TaskModel task) async {
    await _db.collection('tasks').doc(task.id).set(task.toMap());
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _db.collection('tasks').doc(taskId).update({'status': status.name});
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }
}
