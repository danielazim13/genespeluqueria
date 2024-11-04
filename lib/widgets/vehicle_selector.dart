import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/vehicle.dart';

class VehicleSelector extends StatefulWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle?> onVehicleSelected;

  const VehicleSelector({
    super.key,
    required this.vehicles,
    required this.onVehicleSelected,
  });

  static Future<List<Vehicle>> loadVehicles() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('vehiculos')
        .where('userID', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
  }

  @override
  _VehicleSelectorState createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    if (widget.vehicles.isEmpty) {
      return const Center(child: Text('No hay vehículos disponibles'));
    }
    return ExpansionTile(
      title: const Text(
        'Seleccionar vehículo',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: false,
      children: widget.vehicles.map((vehicle) {
        return RadioListTile<Vehicle>(
          title: Text('${vehicle.brand} ${vehicle.model}'),
          value: vehicle,
          groupValue: _selectedVehicle,
          onChanged: (value) {
            setState(() {
              _selectedVehicle = value;
              widget.onVehicleSelected(value);
            });
          },
        );
      }).toList(),
    );
  }
}
