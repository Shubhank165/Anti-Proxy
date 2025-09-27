import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../models/class_model.dart';
import '../../models/student_model.dart';
import 'class_detail_page.dart';
import 'enroll_class_page.dart';
import 'history_page.dart';

// Using simple mock data to power the UI for the demo
class MockTeacherClass {
  final String name;
  final String id;
  final int studentCount;
  final Color color;

  MockTeacherClass({
    required this.name,
    required this.id,
    required this.studentCount,
    required this.color,
  });
}

final List<MockTeacherClass> mockTeacherClasses = [
  MockTeacherClass(name: "Software Engineering", id: "CS-301", studentCount: 40, color: Colors.deepPurpleAccent),
  MockTeacherClass(name: "Advanced Algorithms", id: "CS-405", studentCount: 40, color: Colors.orangeAccent),
];

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Attendance History',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const HistoryPage(),
              ));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=60'),
              ),
              onPressed: () {
                // TODO: Implement profile action
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockTeacherClasses.length,
        itemBuilder: (context, index) {
          final enrolledClass = mockTeacherClasses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.15),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                final List<String> studentNames = [
                  'sukriti', 'taher', 'ujjwal', 'vishrut', 'vivaan', 'aarushi', 'aaryaman', 'abhinav',
                  'akansh', 'aman', 'amlan', 'aneesh', 'anugya', 'armaan', 'arpit', 'aryanb', 'avyaan',
                  'devansh', 'dheeraj', 'himani', 'ishansh', 'kartik', 'kushagra', 'kushal', 'mayank',
                  'naman', 'nikunj', 'odwitiiyo', 'pihu', 'pranay', 'prisha', 'riddhi', 'ridhwan',
                  'rudransh', 'saksham_jain', 'sarthak', 'shanjan', 'shivaay', 'shreshth', 'shubhank'
                ];

                final classDetail = ClassModel(
                  id: enrolledClass.id,
                  name: enrolledClass.name,
                  students: studentNames.map((name) {
                    final rno = '${enrolledClass.id}-${name.replaceAll('_', '').substring(0, 3)}';
                    return StudentModel(rno: rno, name: name, photoUrl: '');
                  }).toList(),
                );

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ClassDetailPage(classModel: classDetail),
                ));
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrolledClass.id,
                      style: GoogleFonts.poppins(
                        color: enrolledClass.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      enrolledClass.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.group, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${enrolledClass.studentCount} Students',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const EnrollClassPage(),
          ));
        },
        label: const Text('New Class'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}