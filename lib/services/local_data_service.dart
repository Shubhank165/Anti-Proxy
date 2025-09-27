import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/recognition_result_model.dart';

class LocalDataService with ChangeNotifier {
  static const _classesKey = 'enrolled_classes';
  static const _historyKey = 'attendance_history';

  List<ClassModel> _classes = [];
  List<AttendanceModel> _history = [];

  List<ClassModel> get classes => _classes;
  List<AttendanceModel> get history => _history;

  LocalDataService() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final classesJson = prefs.getString(_classesKey);
    if (classesJson != null) {
      final List<dynamic> decoded = jsonDecode(classesJson);
      _classes = decoded.map((item) => ClassModel.fromJson(item)).toList();
    }

    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history = decoded.map((item) => AttendanceModel.fromJson(item)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_classesKey, jsonEncode(_classes.map((c) => c.toJson()).toList()));
    await prefs.setString(_historyKey, jsonEncode(_history.map((h) => h.toJson()).toList()));
  }

  Future<void> enrollClass({
    required String classId,
    required String className,
    required List<StudentModel> students,
  }) async {
    final newClass = ClassModel(id: classId, name: className, students: students);
    _classes.add(newClass);
    await _saveData();
    notifyListeners();
  }

  // UPDATED THIS METHOD
  void addHistoryRecord({
    required String classId,
    required String className,
    required String photoPath,
    required String processedPhotoPath,
    required List<RecognitionResultModel> recognitionResults,
    required String teacherName,
    required Map<String, String> studentStatus, // <-- Added this required parameter
  }) async {
    final record = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      classId: classId,
      className: className,
      photoUrl: photoPath,
      processedPhotoUrl: processedPhotoPath,
      recognitionResults: recognitionResults,
      capturedAt: DateTime.now(),
      teacherName: teacherName,
      studentStatus: studentStatus, // <-- Passed it to the constructor
    );
    _history.insert(0, record);
    await _saveData();
    notifyListeners();
  }
}