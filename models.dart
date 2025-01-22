class Task {
  String id;
  String projectId;
  String title;
  String description;
  DateTime dueDate;
  String priority;
  String status;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
  });
}
