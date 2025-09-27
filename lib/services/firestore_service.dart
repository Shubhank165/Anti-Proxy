import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  // Collections:
  CollectionReference<Map<String, dynamic>> get classesCol =>
      _db.collection('teachers').doc(_uid).collection('classes');

  CollectionReference<Map<String, dynamic>> studentsCol(String classId) =>
      classesCol.doc(classId).collection('students');

  CollectionReference<Map<String, dynamic>> get historyCol =>
      _db.collection('teachers').doc(_uid).collection('history');

  Future<String> createClass(String name) async {
    final doc = await classesCol.add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> addStudent({
    required String classId,
    required String name,
    required String rollNo,
    String? photoUrl, // ✅ now nullable
  }) async {
    await studentsCol(classId).doc(rollNo).set({
      'name': name,
      'rno': rollNo,
      'photoUrl': photoUrl ?? '', // ✅ safely default to empty string
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addHistory({
    required String classId,
    required String className,
    required String photoStoragePath,
    String? photoUrl, // ✅ also allow null here
  }) async {
    await historyCol.add({
      'classId': classId,
      'className': className,
      'photoPath': photoStoragePath,
      'photoUrl': photoUrl ?? '',
      'capturedAt': FieldValue.serverTimestamp(),
    });
  }
}
