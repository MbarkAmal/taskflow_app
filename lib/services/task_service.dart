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

  Future<void> deleteProject(String projectId) async {
    // 1. Delete all tasks in the project
    final tasks = await _db.collection('tasks').where('projectId', isEqualTo: projectId).get();
    for (var doc in tasks.docs) {
      await doc.reference.delete();
    }
    // 2. Delete the project itself
    await _db.collection('projects').doc(projectId).delete();
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
    // 1. Save the task
    await _db.collection('tasks').doc(task.id).set(task.toMap());

    // 2. Automatically add the assigned user to the project members so it shows in their dashboard
    await _db.collection('projects').doc(task.projectId).update({
      'memberIds': FieldValue.arrayUnion([task.assignedToId])
    });
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _db.collection('tasks').doc(taskId).update({'status': status.name});
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }

  // --- USERS ---

  Stream<List<UserModel>> getUsers() {
    return _db.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList());
  }
}
