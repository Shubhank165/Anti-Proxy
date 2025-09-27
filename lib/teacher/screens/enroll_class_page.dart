import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../common/app_colors.dart';
import '../../models/student_model.dart';
import '../../services/local_data_service.dart';

class EnrollClassPage extends StatefulWidget {
  const EnrollClassPage({super.key});

  @override
  State<EnrollClassPage> createState() => _EnrollClassPageState();
}

class _EnrollClassPageState extends State<EnrollClassPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _classIdCtrl = TextEditingController();
  final TextEditingController _classNameCtrl = TextEditingController();
  String? _pickedPath;
  String? _fileName;
  bool _busy = false;

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedPath = result.files.single.path;
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking file: $e"), backgroundColor: AppColors.absent),
      );
    }
  }

  Future<void> _enrollClass() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a student CSV file."),
        backgroundColor: AppColors.absent,
      ));
      return;
    }

    setState(() => _busy = true);

    try {
      final file = File(_pickedPath!);
      final content = utf8.decode(await file.readAsBytes());
      final rows = const CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(content);

      if (rows.length < 2) throw Exception("CSV file must contain a header and at least one student.");

      final List<StudentModel> students = [];
      // Start from 1 to skip header row
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length >= 3) { // Assuming format: rollno,name,photourl
          students.add(StudentModel(
            rno: row[0].toString().trim(),
            name: row[1].toString().trim(),
            photoUrl: row[2].toString().trim(),
          ));
        }
      }

      if (students.isEmpty) throw Exception("No valid student data found.");

      // Use Provider to access the LocalDataService
      await context.read<LocalDataService>().enrollClass(
        classId: _classIdCtrl.text.trim(),
        className: _classNameCtrl.text.trim(),
        students: students,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Class '${_classNameCtrl.text}' enrolled successfully!"), backgroundColor: AppColors.present),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.absent));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enroll New Class"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader("Step 1: Class Details"),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classIdCtrl,
                decoration: _buildInputDecoration("Class ID (e.g., CS-301)"),
                validator: (v) => v!.trim().isEmpty ? 'Class ID is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classNameCtrl,
                decoration: _buildInputDecoration("Class Name (e.g., Software Engineering)"),
                validator: (v) => v!.trim().isEmpty ? 'Class Name is required' : null,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader("Step 2: Upload Student List (CSV)"),
              const SizedBox(height: 8),
              Text(
                "CSV format: rollno,name,photourl (no header)",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickCsvFile,
                icon: const Icon(Icons.attach_file_rounded),
                label: Text(_fileName ?? "Select Student CSV File"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (_busy)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _enrollClass,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Enroll Class",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}