//import 'package:app/core/router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/turno.dart';
import 'package:go_router/go_router.dart';

class ClienteListaTurnosScreen extends StatelessWidget {
  final String? userId;

  const ClienteListaTurnosScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final effectiveUserId = userId ?? FirebaseAuth.instance.currentUser?.uid;

    if (effectiveUserId == null) {
      return const Center(child: Text('No has iniciado sesión'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis turnos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('turns')
            .where('usuario.id', isEqualTo: effectiveUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los turnos'));
          }

          final data = snapshot.requireData;
          List<Turn> turns =
              data.docs.map((doc) => Turn.fromFirestore(doc)).toList();

          if (turns.isEmpty) {
            return const Center(child: Text('No hay turnos disponibles'));
          }

          List<Turn> inProgressTurns = turns
              .where((turn) =>
                  turn.estado == 'Pendiente' ||
                  turn.estado == 'Confirmado' ||
                  turn.estado == 'En Progreso')
              .toList();

          List<Turn> doneTurns =
              turns.where((turn) => turn.estado == 'Realizado').toList();

          return _ListTurnView(
            inProgressTurns: inProgressTurns,
            doneTurns: doneTurns,
          );
        },
      ),
    );
  }
}

class _ListTurnView extends StatelessWidget {
  final List<Turn> inProgressTurns;
  final List<Turn> doneTurns;

  const _ListTurnView({
    required this.inProgressTurns,
    required this.doneTurns,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (inProgressTurns.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Turnos en progreso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...inProgressTurns.map((turn) => _TurnItem(turn: turn)).toList(),
          const Divider(),
        ],
        if (doneTurns.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Turnos Finalizados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...doneTurns.map((turn) => _TurnItem(turn: turn)).toList(),
          const Divider(),
        ],
      ],
    );
  }
}

class _TurnItem extends StatelessWidget {
  final Turn turn;

  const _TurnItem({required this.turn});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha: ${turn.ingreso.toString().split(' ')[0]} ${turn.ingreso.toString().split(' ')[1].substring(0, 5)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            ...turn.servicios.map((servicio) => Text(
              '${servicio.nombre}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            )),
          ],
        ),
        onTap: () {
          if (turn.estado == 'Pendiente' ||
              turn.estado == 'Confirmado' ||
              turn.estado == 'En Progreso') {
            context.push('/cliente/turno/reprogramar/${turn.id}');
          }
        },
      ),
    );
  }
}