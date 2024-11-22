import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/entities/servicio.dart';
import 'package:app/entities/usuario.dart';

class Turn {
  final String? id;
  final Usuario usuario;
  final List<Servicio> servicios;
  final DateTime ingreso;
  final String estado;
  final double precio;
  final int duracion;
  final String mensaje;

  Turn({
    this.id,
    required this.usuario,
    required this.servicios,
    required this.ingreso,
    required this.estado,
    required this.precio,
    required this.duracion,
    required this.mensaje,
  });

  factory Turn.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse Usuario data
    Usuario usuario = Usuario.fromMap(data['usuario'] as Map<String, dynamic>);

    // Parse Servicios data
    List<Servicio> servicios = (data['servicios'] as List<dynamic>)
        .map((servicioData) => Servicio.fromMap(servicioData as Map<String, dynamic>))
        .toList();

    return Turn(
      id: doc.id,
      usuario: usuario,
      servicios: servicios,
      ingreso: (data['ingreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: data['estado'] ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0.0,
      duracion: (data['duracion'] as num?)?.toInt() ?? 0,
      mensaje: data['mensaje'] as String? ?? '',
    );
  }

  get servicio => null;

  Map<String, dynamic> toFirestore() {
    return {
      'usuario': usuario.toMap(),
      'servicios': servicios.map((servicio) => servicio.toMap()).toList(),
      'ingreso': ingreso,
      'estado': estado,
      'precio': precio,
      'duracion': duracion,
      'mensaje': mensaje,
    };
  }
}
