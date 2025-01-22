import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_task_screen.dart';
import 'task_service.dart'; // Import TaskService

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;
  ProjectDetailsScreen({required this.projectId});

  final TaskService _taskService =
      TaskService(); // Create instance of TaskService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('projects')
            .doc(projectId)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text('No project details found.'));
          }

          final project = snapshot.data!.data() as Map<String, dynamic>;
          final tasks = project['tasks'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Title and Status
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['title'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${project['status']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Task List
                Text(
                  'Tasks:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        elevation: 4,
                        child: ListTile(
                          title: Text(task['title']),
                          subtitle: Text('Due: ${task['dueDate']}'),
                          leading: Icon(Icons.check_box),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Navigate to edit task screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTaskScreen(
                                          projectId: projectId, task: task),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Pass the task document ID to delete the task
                                  _taskService.deleteTask(
                                      projectId,
                                      task[
                                          'taskDocumentId'], // Use taskDocumentId
                                      context);
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            // Handle task tap if necessary
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(projectId: projectId),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
