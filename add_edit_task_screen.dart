import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditProjectScreen extends StatefulWidget {
  final String? projectId; // Pass this if editing an existing project

  AddEditProjectScreen({this.projectId});

  @override
  _AddEditProjectScreenState createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form fields
  String _title = '';
  String _description = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'Pending';

  bool _isLoading = false; // For loading feedback

  @override
  void initState() {
    super.initState();
    if (widget.projectId != null) {
      _loadProjectDetails();
    }
  }

  Future<void> _loadProjectDetails() async {
    try {
      final doc =
          await _firestore.collection('projects').doc(widget.projectId).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _title = data['title'];
          _description = data['description'];
          _startDate = (data['startDate'] as Timestamp).toDate();
          _endDate = (data['endDate'] as Timestamp).toDate();
          _status = data['status'];
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load project details.')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final projectData = {
        'title': _title,
        'description': _description,
        'startDate': _startDate,
        'endDate': _endDate,
        'status': _status,
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        if (widget.projectId == null) {
          // Add new project
          await _firestore.collection('projects').add(projectData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Project added successfully!')),
          );
        } else {
          // Update existing project
          await _firestore
              .collection('projects')
              .doc(widget.projectId)
              .update(projectData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Project updated successfully!')),
          );
        }
        Navigator.of(context).pop(); // Navigate back to the previous screen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save project. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProject() async {
    try {
      await _firestore.collection('projects').doc(widget.projectId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project deleted successfully!')),
      );
      Navigator.of(context).pop(); // Navigate back to the previous screen
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete project.')),
      );
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectId == null ? 'Add Project' : 'Edit Project'),
        backgroundColor: Colors.purple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Title Input
                    TextFormField(
                      initialValue: _title,
                      decoration: InputDecoration(
                        labelText: 'Project Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Title is required' : null,
                      onSaved: (value) => _title = value!,
                    ),
                    SizedBox(height: 16),

                    // Description Input
                    TextFormField(
                      initialValue: _description,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      maxLines: 3,
                      onSaved: (value) => _description = value!,
                    ),
                    SizedBox(height: 16),

                    // Start Date Picker
                    ListTile(
                      title: Text(
                          'Start Date: ${_startDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _pickDate(context, true),
                    ),
                    SizedBox(height: 16),

                    // End Date Picker
                    ListTile(
                      title: Text(
                          'End Date: ${_endDate?.toLocal().toString().split(' ')[0] ?? 'Select Date'}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _pickDate(context, false),
                    ),
                    SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: ['Pending', 'In Progress', 'Completed']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _status = value!),
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        widget.projectId == null
                            ? 'Add Project'
                            : 'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    // Delete Button (only visible for editing)
                    if (widget.projectId != null) ...[
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _deleteProject,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                        child: Text('Delete Project'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
