import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../common/app_colors.dart';
import '../../services/local_data_service.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Date formatter for a clean look
    final fmt = DateFormat('dd MMMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: Consumer<LocalDataService>(
        builder: (context, dataService, child) {
          if (dataService.history.isEmpty) {
            return const Center(
              child: Text(
                'No attendance records found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: dataService.history.length,
            itemBuilder: (context, index) {
              final record = dataService.history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => HistoryDetailPage(attendanceRecord: record),
                    ));
                  },
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(record.photoUrl),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    record.className,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textColor),
                  ),
                  subtitle: Text(fmt.format(record.capturedAt)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}