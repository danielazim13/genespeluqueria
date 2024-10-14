import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:app/entities/turno.dart';

class ReparationHistoryScreen extends StatelessWidget {
  static const String name = 'reparation-history-screen';

  const ReparationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reparaciones'),
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
                .collection('turnos')
                .where('userId', isEqualTo: userId)
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
              'Turnos en Progreso',
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

Icon _getStateIcon(String state) {
  switch (state) {
    case 'Pendiente':
      return const Icon(Icons.pending, color: Colors.orange, size: 48);
    case 'Confirmado':
      return const Icon(Icons.check_circle, color: Colors.green, size: 48);
    case 'En Progreso':
      return const Icon(Icons.autorenew, color: Colors.blue, size: 48);
    case 'Realizado':
      return const Icon(Icons.done, color: Colors.purple, size: 48);
    case 'Cancelado':
      return const Icon(Icons.cancel, color: Colors.red, size: 48);
    default:
      return const Icon(Icons.help, color: Colors.grey, size: 48);
  }
}

class _TurnItem extends StatelessWidget {
  final Turn turn;

  const _TurnItem({required this.turn});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserDetails(turn.usuarioId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }
        if (userSnapshot.hasError) {
          return const Text('Error al cargar detalles del usuario');
        }
        if (!userSnapshot.hasData) {
          return const Text('Detalles del usuario no encontrados');
        }

        final userData = userSnapshot.data!;
        final String userName = userData['nombre'] ?? 'Desconocido'; // Nombre del usuario

        return FutureBuilder<Map<String, dynamic>>(
          future: _getVehicleDetails(turn.usuarioId),
          builder: (context, vehicleSnapshot) {
            if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (vehicleSnapshot.hasError) {
              return const Text('Error al cargar detalles del vehículo');
            }
            if (!vehicleSnapshot.hasData) {
              return const Text('Detalles del vehículo no encontrados');
            }

            final vehicleData = vehicleSnapshot.data!;
            final String vehicleBrand = vehicleData['brand'] ?? 'Desconocido';
            final String vehicleModel = vehicleData['model'] ?? 'Desconocido';

            return Card(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🚗'),
                        const SizedBox(
                            width: 8), // Espacio entre el emoji y el texto
                        Text('$vehicleBrand $vehicleModel'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ingreso: ${turn.ingreso.toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    //Text(
                    //  'Egreso: ${turn.egreso.toString().split('.')[0]}',
                    //  style: const TextStyle(fontSize: 12, color: Colors.grey),
                    //),
                  ],
                ),
                trailing: _getStateIcon(turn.estado),
                onTap: () { }
                //  context.push('/cliente/turn-progress',
                //      extra: TurnDetails(
                //          userName: userName,
                //          vehicleBrand: vehicleBrand,
                //          vehicleModel: vehicleModel,
                //          ingreso: turn.ingreso,
                //          turnState: turn.estado,
                //          egreso: turn.egreso));
                //},
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('usuarios').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> _getVehicleDetails(String vehicleId) async {
    final vehicleDoc = await FirebaseFirestore.instance
        .collection('vehiculos')
        .doc(vehicleId)
        .get();
    return vehicleDoc.data() as Map<String, dynamic>? ?? {};
  }
}