import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PeluquerosConfigScreen extends StatefulWidget {
  const PeluquerosConfigScreen({super.key});

  @override
  _PeluquerosConfigScreenState createState() => _PeluquerosConfigScreenState();
}

class _PeluquerosConfigScreenState extends State<PeluquerosConfigScreen> {
  final TextEditingController _cantidadController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Load current number of hairdressers
    _fetchCurrentCantidad();
  }

  Future<void> _fetchCurrentCantidad() async {
    try {
      final docSnapshot = await _firestore
          .collection('configuration')
          .doc('peluqueros')
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _cantidadController.text = docSnapshot.data()?['cantidad']?.toString() ?? '0';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> _updateCantidad() async {
    final cantidad = int.tryParse(_cantidadController.text) ?? 0;

    try {
      await _firestore
          .collection('configuration')
          .doc('peluqueros')
          .set({'cantidad': cantidad}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad de peluqueros actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error actualizando datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración de Peluqueros'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad de Peluqueros',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateCantidad,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Actualizar Cantidad'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }
}
