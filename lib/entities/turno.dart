import 'package:cloud_firestore/cloud_firestore.dart';

class Turn {
  final String? id;
  final String usuarioId;
  final List<String> servicios;
  final DateTime ingreso;
  final String estado;
  final double precio;
  final DateTime egreso;
  final String mensaje;

  Turn(
      {this.id,
      required this.usuarioId,
      required this.servicios,
      required this.ingreso,
      required this.estado,
      required this.precio,
      required this.egreso,
      required this.mensaje});

  factory Turn.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Turn(
      id: doc.id,
      usuarioId: data['usuarioId'] as String? ?? '',
      servicios: List<String>.from(data['servicios'] ?? []),
      ingreso: (data['ingreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      egreso: (data['egreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: data['estado'] ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      mensaje: data['mensaje'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'servicios': servicios,
      'ingreso': ingreso,
      'egreso': egreso,
      'estado': estado,
      'precio': precio,
      'mensaje': mensaje,
    };
  }
}
