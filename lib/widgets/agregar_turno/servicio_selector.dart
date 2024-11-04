import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/servicio.dart';

class ServicioSelector extends StatefulWidget {
  final List<Servicio> servicios;
  final ValueChanged<Set<Servicio>> onServiciosSelected;

  const ServicioSelector({
    super.key,
    required this.servicios,
    required this.onServiciosSelected,
  });

  static Future<List<Servicio>> loadServicios() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('servicios').get();
    return snapshot.docs.map((doc) => Servicio.fromFirestore(doc)).toList();
  }

  @override
  _ServicioSelectorState createState() => _ServicioSelectorState();
}

class _ServicioSelectorState extends State<ServicioSelector> {
  final Set<Servicio> _selectedServicios = {};
  int _totalDuracion = 0;

  void _updateSelectedServicios(Servicio servicio, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedServicios.add(servicio);
      } else {
        _selectedServicios.remove(servicio);
      }

      _totalDuracion = _selectedServicios.fold(
          0, (total, servicio) => total + servicio.duracion);

      widget.onServiciosSelected(_selectedServicios);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.servicios.isEmpty) {
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
            children: widget.servicios.map((servicio) {
              return CheckboxListTile(
                title: Row(
                  children: [
                    Text(servicio.nombre),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          '\$${servicio.precio.toStringAsFixed(0)} (⌚${servicio.duracion}\')',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
                value: _selectedServicios.contains(servicio),
                onChanged: (checked) {
                  _updateSelectedServicios(servicio, checked!);
                },
              );
            }).toList(),
          ),
        ],
      );
    }
  }
}
