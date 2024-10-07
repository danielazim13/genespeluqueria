import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  final String id;
  final String nombre;
  final double precio;
  final int duracion;

  Servicio({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.duracion,
  });

  factory Servicio.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Servicio(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      precio: data['precio'] ?? 0.0,
      duracion: data['duracion'] ?? 0
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'precio': precio,
      'duracion': duracion,
    };
  }
}
