import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nombre;
  final String telefono;
  final bool esAdmin;

  Usuario(
      {required this.id,
      required this.nombre,
      required this.telefono,
      required this.esAdmin});

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      telefono: data['telefono'] ?? '',
      esAdmin: data['esAdmin'] ?? false,
    );
  }
}
