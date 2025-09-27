import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<(String path, String url)> uploadAttendancePhoto({
    required String classId,
    required File file,
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final path = 'attendance/$_uid/$classId/$ts.jpg';
    final ref = _storage.ref().child(path);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    return (path, url);
  }
}
