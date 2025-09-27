import 'package:flutter/material.dart';
import '../../common/course_card.dart';
import 'course_detail_screen.dart';

// Mock data for courses
const List<Map<String, String>> mockCourses = [
  {"name": "Advanced Flutter Development", "teacher": "Dr. Ada Lovelace", "color": "0xFF7E57C2"},
  {"name": "Data Structures & Algorithms", "teacher": "Prof. Charles Babbage", "color": "0xFF42A5F5"},
  {"name": "Introduction to Machine Learning", "teacher": "Dr. Alan Turing", "color": "0xFF26A69A"},
  {"name": "Software Engineering Principles", "teacher": "Prof. Grace Hopper", "color": "0xFFFF7043"},
  {"name": "Database Management Systems", "teacher": "Dr. Edgar Codd", "color": "0xFFEF5350"},
];

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Placeholder avatar
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockCourses.length,
        itemBuilder: (context, index) {
          final course = mockCourses[index];
          return CourseCard(
            courseName: course['name']!,
            teacherName: course['teacher']!,
            color: Color(int.parse(course['color']!)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(courseName: course['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}