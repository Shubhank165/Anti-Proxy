class StudentModel {
  final String rno;
  final String name;
  final String photoUrl;

  StudentModel({required this.rno, required this.name, required this.photoUrl});

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      rno: json['rno'],
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rno': rno,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}