import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Updated to use document ID (Firebase auto-generated)
  Future<void> deleteTask(
      String projectId, String taskDocumentId, BuildContext context) async {
    try {
      // Get the project document
      final projectDoc =
          await _firestore.collection('projects').doc(projectId).get();
      final projectData = projectDoc.data() as Map<String, dynamic>;

      // Get the tasks list from the project document
      final tasks = projectData['tasks'] ?? [];

      // Find the task document ID to delete it from the tasks list
      final taskToDelete = tasks.firstWhere(
        (task) => task['taskDocumentId'] == taskDocumentId,
        orElse: () => null,
      );

      if (taskToDelete != null) {
        // If task found, remove the task from the 'tasks' array
        await _firestore.collection('projects').doc(projectId).update({
          'tasks': FieldValue.arrayRemove([taskToDelete]),
        });

        // Delete the task document using its ID
        await _firestore.collection('tasks').doc(taskDocumentId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task not found')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task')),
      );
    }
  }
}
