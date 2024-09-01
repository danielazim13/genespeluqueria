import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final double price;
  final int diasAproximados;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.diasAproximados,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0.0,
      diasAproximados: data['diasAproximados'] ?? 0
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'diasAproximados': diasAproximados,
    };
  }
}
