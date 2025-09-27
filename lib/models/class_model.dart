import 'student_model.dart';

class ClassModel {
  final String id;
  final String name;
  final List<StudentModel> students;

  ClassModel({required this.id, required this.name, this.students = const []});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    var studentList = json['students'] as List;
    List<StudentModel> students = studentList.map((i) => StudentModel.fromJson(i)).toList();
    return ClassModel(
      id: json['id'],
      name: json['name'],
      students: students,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'students': students.map((s) => s.toJson()).toList(),
    };
  }
}