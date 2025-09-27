import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../models/class_model.dart';
import '../../models/recognition_result_model.dart';
import '../../services/api_service.dart';
import '../../services/local_data_service.dart';

class ClassDetailPage extends StatefulWidget {
  final ClassModel classModel;
  const ClassDetailPage({super.key, required this.classModel});

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  final ApiService _apiService = ApiService();
  Map<String, String> _attendanceStatus = {};

  Future<void> _markAttendanceWithAPI() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      );

      if (source == null || !mounted) return;

      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: source, imageQuality: 85);
      if (xfile == null || !mounted) return;

      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(xfile.path), height: 200),
              const SizedBox(height: 16),
              const Text('Process attendance for this photo?'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Process')),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final file = File(xfile.path);
        final (processedImagePath, recognitionResults) = await _apiService.processImageForAttendance(file);

        final fullStatusMap = _updateAttendanceFromResults(recognitionResults);

        context.read<LocalDataService>().addHistoryRecord(
          classId: widget.classModel.id,
          className: widget.classModel.name,
          photoPath: xfile.path,
          processedPhotoPath: processedImagePath,
          recognitionResults: recognitionResults,
          teacherName: "Teacher",
          studentStatus: fullStatusMap,
        );

        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing complete! ${recognitionResults.length} face(s) identified.'), backgroundColor: AppColors.present),
        );
      }
    } catch (e) {
      debugPrint("Error marking attendance with API: $e");
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.absent),
        );
      }
    }
  }

  Map<String, String> _updateAttendanceFromResults(List<RecognitionResultModel> results) {
    final statuses = <String, String>{};
    final recognizedNames = results.map((r) => r.name.toLowerCase()).toSet();

    for (var student in widget.classModel.students) {
      if (recognizedNames.contains(student.name.toLowerCase())) {
        statuses[student.rno] = 'Present';
      } else {
        statuses[student.rno] = 'Absent';
      }
    }
    setState(() {
      _attendanceStatus = statuses;
    });
    return statuses;
  }

  void _showAttendanceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mark Attendance",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text("Use Face Recognition (API)"),
              onTap: () {
                Navigator.pop(context);
                _markAttendanceWithAPI();
              },
            ),
            ListTile(
              leading: const Icon(Icons.swipe, color: Colors.deepPurpleAccent),
              title: const Text("Manual Swipe Attendance"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual Swipe feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel.name),
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.classModel.students.length,
        itemBuilder: (context, index) {
          final student = widget.classModel.students[index];
          final status = _attendanceStatus[student.rno];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  student.name.isNotEmpty ? student.name.substring(0, 1) : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Roll No: ${student.rno}'),
              trailing: status == null
                  ? const SizedBox.shrink()
                  : Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Present'
                      ? AppColors.present.withOpacity(0.15)
                      : AppColors.absent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Present' ? AppColors.present : AppColors.absent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAttendanceOptions,
        label: const Text("Take Attendance"),
        icon: const Icon(Icons.check_circle_outline),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}