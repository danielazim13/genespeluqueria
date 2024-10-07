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
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _duracionController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  Future<void> _agregarServicio() async {
    if (_formKey.currentState!.validate()) {
      // Obtener la referencia del nuevo documento en la colección 'servicios'
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('servicios')
          .doc();

      // Crear una instancia de Service con el ID generado por Firebase
      Servicio newService = Servicio(
        id: docRef.id,
        nombre: _nombreController.text,
        precio: double.parse(_precioController.text),
        duracion: int.parse(_duracionController.text),
      );

      // Guardar el servicio en Firestore
      await docRef.set(newService.toFirestore());

      // Mostrar un mensaje de éxito y regresar a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio agregado exitosamente')),
      );

      // Regresar a la pantalla anterior
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Servicio'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Servicio'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del servicio';
                  }
                  return null;
                },
              ),
              // Precio
              TextFormField(
                controller: _precioController,
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
              // Duración
              TextFormField(
                controller: _duracionController,
                decoration: const InputDecoration(labelText: 'Duración aproximada (minutos)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese los minutos aproximados';
                  }
                  int? dias = int.tryParse(value);
                  if (dias == null) {
                    return 'Por favor, ingrese un número válido';
                  }
                  if (dias < 1 || dias > 540) {
                    return 'Por favor, ingrese un valor entre 1 y 540 minutos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarServicio,
                child: const Text('Agregar Servicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}