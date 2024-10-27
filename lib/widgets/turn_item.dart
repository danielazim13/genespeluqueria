import 'package:app/entities/turno.dart';
import 'package:app/entities/usuario.dart';
import 'package:app/screens/admin/turnos/detalle_turno_screen.dart';
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
    String formattedDate = DateFormat('dd/MM/yy').format(turn.ingreso);
    String formattedTime = DateFormat('HH:mm').format(turn.ingreso);

    return Card(
      child: ListTile(
        leading: _getStateIcon(turn.estado),
        title: Text('Lorem ipsum'), // Text(user.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate),
            Text(formattedTime),
          ],
        ),
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
