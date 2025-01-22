import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  final String projectId;
  final Map<String, dynamic>? task; // Optional parameter for editing

  AddTaskScreen({required this.projectId, this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime? _dueDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _isEditing = true;
      _title = widget.task!['title'] ?? '';
      _dueDate = widget.task!['dueDate'] != null
          ? DateTime.parse(widget.task!['dueDate'])
          : null;
    }
  }

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final taskData = {
        'title': _title,
        'dueDate': _dueDate?.toIso8601String(),
      };

      try {
        if (_isEditing) {
          // Update the task in Firestore
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(widget.projectId)
              .update({
            'tasks': FieldValue.arrayRemove([widget.task]),
          });

          await FirebaseFirestore.instance
              .collection('projects')
              .doc(widget.projectId)
              .update({
            'tasks': FieldValue.arrayUnion([taskData]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task updated successfully!')),
          );
        } else {
          // Add the task to Firestore
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(widget.projectId)
              .update({
            'tasks': FieldValue.arrayUnion([taskData]),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task added successfully!')),
          );
        }

        Navigator.of(context).pop(); // Go back to ProjectDetailsScreen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task. Please try again.')),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    if (_isEditing && widget.task != null) {
      try {
        // Remove the task from Firestore
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(widget.projectId)
            .update({
          'tasks': FieldValue.arrayRemove([widget.task]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted successfully!')),
        );

        Navigator.of(context).pop(); // Go back to ProjectDetailsScreen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete task.')),
        );
      }
    }
  }

  Future<void> _pickDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        backgroundColor: Colors.blueAccent,
        actions: _isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteTask, // Calling _deleteTask method
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Task title is required' : null,
                onSaved: (value) => _title = value!,
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: _pickDueDate,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          'Due Date: ${_dueDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'}'),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
