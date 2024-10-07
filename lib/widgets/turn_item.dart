import 'package:app/entities/turn.dart';
import 'package:app/entities/user.dart';
import 'package:app/screens/admin/turnos/turnos_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TurnItem extends StatelessWidget {
  final Turn turn;
  final Function actualizadoPagina;

  const TurnItem(
      {super.key, required this.turn, required this.actualizadoPagina});

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(turn.ingreso);

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(turn.userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If waiting, show a placeholder widget or return an empty container
          return Container();
        }
        if (snapshot.hasError) {
          return const Text('Error al cargar usuario');
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Usuario no encontrado');
        }

        User user = User.fromFirestore(snapshot.data!);

        return Card(
          child: ListTile(
            leading: _getStateIcon(turn.state),
            title: Text(user.name),
            subtitle: Text(formattedDate),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TurnoDetailsScreen(turn: turn),
                ),
              );
              actualizadoPagina();
            },
          ),
        );
      },
    );
  }

  Icon _getStateIcon(String state) {
    switch (state) {
      case 'Pendiente':
        return const Icon(Icons.pending, color: Colors.orange);
      case 'Confirmado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'En Progreso':
        return const Icon(Icons.autorenew, color: Colors.blue);
      case 'Realizado':
        return const Icon(Icons.done, color: Colors.purple);
      case 'Cancelado':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }
}