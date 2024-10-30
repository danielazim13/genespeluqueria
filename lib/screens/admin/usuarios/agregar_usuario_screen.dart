import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/entities/usuario.dart';

class AgregarUsuarioScreen extends StatefulWidget {
  const AgregarUsuarioScreen({super.key});

  @override
  _AgregarUsuarioScreenState createState() => _AgregarUsuarioScreenState();
}

class _AgregarUsuarioScreenState extends State<AgregarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _agregarUsuario() async {
    if (_formKey.currentState!.validate()) {
      // Obtener la referencia del nuevo documento en la colección 'usuarios'
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc();

      // Crear una instancia de Service con el ID generado por Firebase
      Usuario newService = Usuario(
        id: docRef.id,
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
      );

      // Guardar el usuario en Firestore
      await docRef.set(newUser.toFirestore());

      // Mostrar un mensaje de éxito y regresar a la pantalla anterior
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario agregado exitosamente')),
      );

      // Regresar a la pantalla anterior
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar usuario'),
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
                decoration: const InputDecoration(labelText: 'Nombre del usuario'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del usuario';
                  }
                  return null;
                },
              ),
              // telefono
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Telefono'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el telefono';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un telefono válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarServicio,
                child: const Text('Agregar usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}