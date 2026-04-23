import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_models.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import 'add_task_screen.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  final ProjectModel project;
  const TaskListScreen({super.key, required this.project});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskProvider>().fetchTasks(widget.project.id);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.name),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks in this project.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _TaskCard(task: task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(projectId: widget.project.id),
            ),
          );
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<TaskProvider>().users;
    final assignedUser = users.firstWhere(
      (u) => u.id == task.assignedToId,
      orElse: () => UserModel(id: '', name: 'Unknown', email: ''),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due: ${DateFormat.yMMMd().format(task.dueDate)}'),
            Text('Assigned to: ${assignedUser.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(task: task),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Task?'),
                    content: Text('Are you sure you want to delete "${task.title}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          context.read<TaskProvider>().deleteTask(task.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        leading: Checkbox(
          value: task.status == TaskStatus.done,
          onChanged: (val) {
            context.read<TaskProvider>().updateTaskStatus(
                  task.id,
                  val! ? TaskStatus.done : TaskStatus.todo,
                );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskModel task;
  const _StatusBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (task.status) {
      case TaskStatus.todo:
        color = Colors.grey;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        break;
      case TaskStatus.done:
        color = Colors.green;
        break;
    }

    return PopupMenuButton<TaskStatus>(
      onSelected: (status) {
        context.read<TaskProvider>().updateTaskStatus(task.id, status);
      },
      itemBuilder: (context) => TaskStatus.values.map((status) {
        return PopupMenuItem(
          value: status,
          child: Text(status.name.toUpperCase()),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          task.status.name.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
