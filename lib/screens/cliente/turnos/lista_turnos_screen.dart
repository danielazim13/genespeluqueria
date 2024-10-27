import 'package:app/core/router.dart';
import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/entities/turno.dart';
import 'package:go_router/go_router.dart';

class ClienteListaTurnosScreen extends StatelessWidget {
  const ClienteListaTurnosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis turnos'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!authSnapshot.hasData) {
            return const Center(child: Text('No has iniciado sesión'));
          }

          final String userId = authSnapshot.data!.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('turns')
                .where('usuarioId', isEqualTo: userId)
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
              print(data);

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
              'Turnos finalizados',
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
            Text('ID: ${turn.id}'),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${turn.ingreso.toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
        onTap: () {
          if(turn.estado =='Pendiente' || turn.estado =='Confirmado' || turn.estado =='En Progreso') {
             context.push('/cliente/turno/reprogramar/${turn.id}');
          }
        },
      ),
    );
  }
}
