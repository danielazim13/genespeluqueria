import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// entities
import 'package:app/entities/peluquero.dart';

class PeluqueroSelector extends StatefulWidget {
  final List<Peluquero> peluqueros;
  final ValueChanged<Peluquero?> onPeluqueroSelected;

  const PeluqueroSelector({
    super.key,
    required this.peluqueros,
    required this.onPeluqueroSelected,
  });

  static Future<List<Peluquero>> loadPeluqueros() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('peluqueros')
        .get();
    return snapshot.docs.map((doc) => Peluquero.fromFirestore(doc)).toList();
  }

  @override
  _PeluqueroSelectorState createState() => _PeluqueroSelectorState();
}

class _PeluqueroSelectorState extends State<PeluqueroSelector> {
  Peluquero? _selectedPeluquero;

  @override
  Widget build(BuildContext context) {
    if (widget.peluqueros.isEmpty) {
      return const Center(child: Text('No hay peluqueros disponibles'));
    }
    return ExpansionTile(
      title: const Text(
        'Seleccionar peluquero (opcional)',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: false,
      children: widget.peluqueros.map((peluquero) {
        return RadioListTile<Peluquero>(
          title: Text(peluquero.name),
          value: peluquero,
          groupValue: _selectedPeluquero,
          onChanged: (value) {
            setState(() {
              _selectedPeluquero = value;
              widget.onPeluqueroSelected(value);
            });
          },
        );
      }).toList(),
    );
  }
}
