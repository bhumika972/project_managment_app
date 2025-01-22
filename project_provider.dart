import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  Future<void> fetchProjects() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('projects').get();
    _projects = snapshot.docs
        .map((doc) => Project(
              id: doc.id,
              title: doc['title'],
              description: doc['description'],
              startDate: DateTime.parse(doc['startDate']),
              endDate: DateTime.parse(doc['endDate']),
              status: doc['status'],
            ))
        .toList();
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    _projects.add(project);
    notifyListeners();
  }
}
