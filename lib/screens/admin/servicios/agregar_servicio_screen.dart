import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/entities/servicio.dart';

class AgregarServicioScreen extends StatefulWidget {
  const AgregarServicioScreen({super.key});

  @override
  _AgregarServicioScreenState createState() => _AgregarServicioScreenState();
}

class _AgregarServicioScreenState extends State<AgregarServicioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _diasAproximadosController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _diasAproximadosController.dispose();
    super.dispose();
  }

  Future<void> _addService() async {
    if (_formKey.currentState!.validate()) {
      // Obtener la referencia del nuevo documento en la colección "services"
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('services')
          .doc();

      // Crear una instancia de Service con el ID generado por Firebase
      Servicio newService = Servicio(
        id: docRef.id,
        nombre: _nameController.text,
        precio: double.parse(_priceController.text),
        duracion: int.parse(_diasAproximadosController.text),
      );

      // Guardar el servicio en Firestore
      await docRef.set(newService.toFirestore());

      // Mostrar un mensaje de éxito y regresar a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio agregado exitosamente')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Servicio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Servicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del servicio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese un precio';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _diasAproximadosController,
                decoration: const InputDecoration(labelText: 'Días aproximados'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese los días aproximados';
                  }
                  int? dias = int.tryParse(value);
                  if (dias == null) {
                    return 'Por favor, ingrese un número válido';
                  }
                  if (dias < 1 || dias > 180) {
                    return 'Por favor, ingrese un valor entre 1 y 180 días';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addService,
                child: const Text('Agregar Servicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}