import 'package:cloud_firestore/cloud_firestore.dart';

class Turn {
  final String? id;
  final String userId;
  final String vehicleId;
  final List<String> services;
  final DateTime ingreso;
  final String state;
  final double totalPrice;
  final DateTime egreso;
  final String message;

  Turn(
      {this.id,
      required this.userId,
      required this.vehicleId,
      required this.services,
      required this.ingreso,
      required this.state,
      required this.totalPrice,
      required this.egreso,
      required this.message});

  factory Turn.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Turn(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      services: List<String>.from(data['services'] ?? []),
      ingreso: (data['ingreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      state: data['state'] ?? '',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      egreso: (data['egreso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      message: data['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'services': services,
      'ingreso': ingreso,
      'egreso': egreso,
      'state': state,
      'totalPrice': totalPrice,
      'message': message,
    };
  }
}
