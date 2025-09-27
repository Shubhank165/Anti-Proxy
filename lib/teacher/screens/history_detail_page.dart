import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../models/student_model.dart'; // We might need this for names if not in the map key

class HistoryDetailPage extends StatefulWidget {
  final AttendanceModel attendanceRecord;
  const HistoryDetailPage({super.key, required this.attendanceRecord});

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  late Map<String, String> _editableStudentStatus;

  @override
  void initState() {
    super.initState();
    // Create a copy of the status map to allow for edits
    _editableStudentStatus = Map.from(widget.attendanceRecord.studentStatus);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Now with a third tab
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.attendanceRecord.className),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Original', icon: Icon(Icons.photo_library_outlined)),
              Tab(text: 'Processed', icon: Icon(Icons.face_retouching_natural_outlined)),
              Tab(text: 'Student List', icon: Icon(Icons.list_alt_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildImageTab(widget.attendanceRecord.photoUrl),
            _buildImageTab(widget.attendanceRecord.processedPhotoUrl),
            _buildEditableStudentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTab(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InteractiveViewer(
        child: Center(child: Image.file(File(imagePath))),
      ),
    );
  }

  Widget _buildEditableStudentList() {
    // Separate students into present and absent lists based on the editable map
    final presentStudents = _editableStudentStatus.entries
        .where((entry) => entry.value == 'Present')
        .toList();
    final absentStudents = _editableStudentStatus.entries
        .where((entry) => entry.value == 'Absent')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Present Section
        _buildStatusSection("Present", presentStudents.length, AppColors.present),
        ...presentStudents.map((entry) => _buildStudentTile(entry.key, true)),
        const SizedBox(height: 24),

        // Absent Section
        _buildStatusSection("Absent", absentStudents.length, AppColors.absent),
        ...absentStudents.map((entry) => _buildStudentTile(entry.key, false)),
      ],
    );
  }

  Widget _buildStatusSection(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
          )
        ],
      ),
    );
  }

  Widget _buildStudentTile(String studentRollNo, bool isPresent) {
    // A simple lookup for the student name from the roll number
    final studentName = studentRollNo; // Assuming roll number is descriptive for now

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(studentName),
        trailing: Switch(
          value: isPresent,
          onChanged: (newValue) {
            setState(() {
              _editableStudentStatus[studentRollNo] = newValue ? 'Present' : 'Absent';
            });
          },
          activeColor: AppColors.present,
        ),
      ),
    );
  }
}