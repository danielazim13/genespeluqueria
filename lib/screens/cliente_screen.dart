import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/widgets/home_screen_base.dart';
import 'package:app/widgets/navigation_button.dart';
import 'package:app/entities/usuario.dart';

class ClienteHomeScreen extends StatelessWidget {
  const ClienteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreenBase(
        title: 'Home (Cliente)',
        buttons: [
          NavigationButton(
            text: 'Solicitar turno',
            icon: Icons.calendar_month,
            route: '/cliente/turno/pedir',
          ),
          //NavigationButton(
          //  text: 'Mis turnos',
          //  icon: Icons.event_note,
          //  route: '/cliente/verTurnos',
          //),
        ],
      ),
    );
  }
}
