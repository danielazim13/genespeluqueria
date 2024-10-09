import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/servicio.dart';
import 'package:app/entities/turno.dart';
import 'package:app/entities/usuario.dart';

class AgendaTurnos extends StatelessWidget {
  final Usuario? currentUser;
  const AgendaTurnos({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return _verTurnos();
  }
}

class _verTurnos extends StatelessWidget {
  const _verTurnos({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis turnos'),
      ),
      body: const Center(
        child: Text('Agregar lista con los turnos del usuario'),
      ),
    );
  }
}
