import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:math';
import '../../common/app_colors.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key});

  @override
  _AttendanceTabState createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  // Mock data: Map of dates to attendance status ('Present' or 'Absent')
  final Map<DateTime, String> _attendanceData = {};
  int _presentDays = 0;
  int _absentDays = 0;

  @override
  void initState() {
    super.initState();
    // Generate random placeholder data for the last 60 days
    final random = Random();
    final today = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final date = today.subtract(Duration(days: i));
      // Simulate classes on weekdays
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        if (random.nextBool()) {
          _attendanceData[DateTime.utc(date.year, date.month, date.day)] = 'Present';
          _presentDays++;
        } else {
          _attendanceData[DateTime.utc(date.year, date.month, date.day)] = 'Absent';
          _absentDays++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalClasses = _presentDays + _absentDays;
    final attendancePercentage = totalClasses == 0 ? 0 : (_presentDays / totalClasses * 100);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Summary Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('Present', '$_presentDays Days', AppColors.present),
              _buildSummaryCard('Absent', '$_absentDays Days', AppColors.absent),
              _buildSummaryCard('Percentage', '${attendancePercentage.toStringAsFixed(1)}%', Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 20),
          // Calendar View
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.now(),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final status = _attendanceData[DateTime.utc(date.year, date.month, date.day)];
                    if (status != null) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status == 'Present' ? AppColors.present : AppColors.absent,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textColor)),
            ],
          ),
        ),
      ),
    );
  }
}