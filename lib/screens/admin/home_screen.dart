import 'package:flutter/material.dart';
import 'package:aplicacion_taller/widgets/home_screen_base.dart';
import 'package:aplicacion_taller/widgets/navigation_button.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenBase(
      title: 'Administrador',
      buttons: [
        NavigationButton(
          text: 'Turnos',
          route: '/administrador/turnos',
          icon: Icon(Icons.calendar_month, size: 90, color: Colors.black),
        ),
      ],
    );
  }
}
