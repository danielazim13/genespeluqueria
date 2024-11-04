import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/service.dart';

class ServiceSelector extends StatefulWidget {
  final List<Service> services;
  final ValueChanged<Set<Service>> onServicesSelected;

  const ServiceSelector({
    super.key,
    required this.services,
    required this.onServicesSelected,
  });

  static Future<List<Service>> loadServices() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('services').get();
    return snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();
  }

  @override
  _ServiceSelectorState createState() => _ServiceSelectorState();
}

class _ServiceSelectorState extends State<ServiceSelector> {
  final Set<Service> _selectedServices = {};
  int _totalDiasAproximados = 0;

  void _updateSelectedServices(Service service, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedServices.add(service);
      } else {
        _selectedServices.remove(service);
      }

      _totalDiasAproximados = _selectedServices.fold(
          0, (total, service) => total + service.diasAproximados);
      widget.onServicesSelected(_selectedServices);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.services.isEmpty) {
      return const Center(child: Text('No hay servicios disponibles'));
    } else {
      return Column(
        children: [
          ExpansionTile(
            title: const Text(
              'Seleccionar servicios',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: false,
            children: widget.services.map((service) {
              return CheckboxListTile(
                title: Row(
                  children: [
                    Text(service.name),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          '${service.diasAproximados} ${service.diasAproximados == 1 ? 'día' : 'días'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                value: _selectedServices.contains(service),
                onChanged: (checked) {
                  _updateSelectedServices(service, checked!);
                },
              );
            }).toList(),
          ),
        ],
      );
    }
  }
}
