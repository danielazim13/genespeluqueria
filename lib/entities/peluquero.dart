import 'package:cloud_firestore/cloud_firestore.dart';

class Peluquero {
  final String id;
  final String name;

  Peluquero({
    required this.id,
    required this.name
  });

  factory Peluquero.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Peluquero(
      id: doc.id,
      name: data['name'] ?? ''
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name
    };
  }
}
