import 'recognition_result_model.dart';

class AttendanceModel {
  final String id;
  final String classId;
  final String className;
  final String photoUrl;
  final String processedPhotoUrl;
  final List<RecognitionResultModel> recognitionResults;
  final DateTime capturedAt;
  final String teacherName;
  // ADD THIS MAP to store the status of every student
  final Map<String, String> studentStatus;

  AttendanceModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.photoUrl,
    required this.processedPhotoUrl,
    required this.recognitionResults,
    required this.capturedAt,
    required this.teacherName,
    required this.studentStatus, // Add to constructor
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    var resultsList = json['recognitionResults'] as List;
    List<RecognitionResultModel> results = resultsList.map((i) => RecognitionResultModel.fromJson(i)).toList();

    return AttendanceModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'],
      photoUrl: json['photoUrl'],
      processedPhotoUrl: json['processedPhotoUrl'],
      recognitionResults: results,
      capturedAt: DateTime.parse(json['capturedAt']),
      teacherName: json['teacherName'],
      // Handle the new map for JSON conversion
      studentStatus: Map<String, String>.from(json['studentStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'photoUrl': photoUrl,
      'processedPhotoUrl': processedPhotoUrl,
      'recognitionResults': recognitionResults.map((r) => r.toJson()).toList(),
      'capturedAt': capturedAt.toIso8601String(),
      'teacherName': teacherName,
      'studentStatus': studentStatus, // Add to JSON
    };
  }
}