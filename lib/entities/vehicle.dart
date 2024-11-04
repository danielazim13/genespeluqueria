import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String model;
  final String brand;
  final String licensePlate;
  final String userID;
  final String? year;

  Vehicle({
    required this.id,
    required this.model,
    required this.brand,
    required this.licensePlate,
    required this.userID,
    this.year,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      model: data['model'] ?? '',
      brand: data['brand'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      userID: data['userID'],
      year: data['year'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'model': model,
      'brand': brand,
      'licensePlate': licensePlate,
      'userID': userID,
      'year': year,
    };
  }
}
