import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cropmgnt/screens/task.dart';
import '../services/task_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskService taskService = TaskService();
  List<Task> tasks = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController resourcesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final loadedTasks = await taskService.getTasks();
      setState(() {
        tasks = loadedTasks;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
    }
  }

  Color _getPriorityColor(String dueDate) {
    try {
      final DateTime now = DateTime.now();
      final DateTime due = DateFormat('yyyy-MM-dd').parse(dueDate);
      final int daysLeft = due.difference(now).inDays;

      if (daysLeft <= 1) return Colors.red;
      if (daysLeft <= 5) return Colors.orange;
      return Colors.green;
    } catch (e) {
      return Colors.grey; // Default color if date parsing fails
    }
  }

  void _addNewTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Due Date (YYYY-MM-DD)',
                    hintText: '2023-12-31',
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: resourcesController,
                  decoration: const InputDecoration(
                    labelText: 'Resources (comma separated)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    dueDateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and Due Date are required'),
                    ),
                  );
                  return;
                }

                try {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    dueDate: dueDateController.text,
                    description: descriptionController.text,
                    resources:
                        resourcesController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                  );

                  await taskService.createTask(newTask);
                  await _loadTasks(); // Refresh the list from the service

                  nameController.clear();
                  dueDateController.clear();
                  descriptionController.clear();
                  resourcesController.clear();

                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add task: $e')),
                  );
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(int index) async {
    final taskId = tasks[index].id;
    try {
      await taskService.deleteTask(taskId);
      await _loadTasks(); // Refresh the list after deletion
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
    }
  }

  Future<void> _toggleTaskCompletion(int index) async {
    try {
      final updatedTask = tasks[index].copyWith(
        isCompleted: !tasks[index].isCompleted,
      );

      await taskService.updateTask(updatedTask);
      await _loadTasks(); // Refresh the list after update
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
    }
  }

  void _viewTaskDetails(int index) {
    final task = tasks[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Due Date: ${task.dueDate}'),
                const SizedBox(height: 8),
                Text('Status: ${task.isCompleted ? 'Completed' : 'Pending'}'),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Description: ${task.description}'),
                ],
                if (task.resources.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Resources:'),
                  Wrap(
                    spacing: 4,
                    children:
                        task.resources
                            .map((resource) => Chip(label: Text(resource)))
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dueDateController.dispose();
    descriptionController.dispose();
    resourcesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTaskDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            tasks.isEmpty
                ? const Center(
                  child: Text(
                    'No tasks available. Add a new task to get started!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Row(
                          children: [
                            Checkbox(
                              value: task.isCompleted,
                              onChanged:
                                  (value) => _toggleTaskCompletion(index),
                            ),
                            Expanded(
                              child: Text(
                                task.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(task.dueDate),
                                  decoration:
                                      task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Due: ${task.dueDate}'),
                            Text(
                              task.isCompleted ? 'Completed' : 'Pending',
                              style: TextStyle(
                                color:
                                    task.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(index),
                        ),
                        onTap: () => _viewTaskDetails(index),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
