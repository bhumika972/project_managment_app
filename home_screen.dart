import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_services.dart';
import 'project_detail_screen.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BuildContext? get context => null;

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text('Project deleted successfully!')),
      );
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text('Failed to delete project')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Projects',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('projects').snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load projects',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final projects = snapshot.data?.docs ?? [];

            if (projects.isEmpty) {
              return Center(
                child: Text(
                  'No projects available. Add one now!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (ctx, index) {
                final project = projects[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        project['title'][0].toUpperCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      project['title'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Status: ${project['status']}',
                      style: TextStyle(color: Colors.black54),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.teal,
                    ),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          ProjectDetailsScreen(projectId: project.id),
                    )),
                    onLongPress: () {
                      // Show options when the project is long pressed (for delete/edit)
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Choose Action'),
                          content: Text(
                              'What would you like to do with this project?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                // Navigate to edit screen
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => AddEditProjectScreen(
                                    projectId: project.id,
                                  ),
                                ));
                              },
                              child: Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                // Delete project
                                _deleteProject(project.id);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddEditProjectScreen(),
          ));
        },
        label: Text('Add Project'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.teal,
        tooltip: 'Create a new project',
      ),
    );
  }
}
