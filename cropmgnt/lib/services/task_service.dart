import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cropmgnt/screens/task.dart';

class TaskService {
  final String baseUrl = 'http://10.0.2.2:8080/api/tasks';

  // Add a connection timeout duration
  final Duration timeout = const Duration(seconds: 10);

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((taskMap) => Task.fromMap(taskMap)).toList();
      } else {
        throw Exception(
          'Failed to load tasks. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(task.toMap()),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        return Task.fromMap(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create task. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/${task.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(task.toMap()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return Task.fromMap(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to update task. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(timeout);

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete task. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}
