import 'package:flutter/material.dart';
import 'package:app/widgets/home_screen_base.dart';
import 'package:app/widgets/navigation_button.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenBase(
      title: 'Home (Admin)',
      buttons: [
        NavigationButton(
          icon: Icons.calendar_month,
          text: 'Agenda',
          route: '/administrador/turnos',
        ),
        NavigationButton(
          icon: Icons.cut,
          text: 'Servicios',
          route: '/admin/servicios/lista',
        ),
         NavigationButton(
          text: 'Horas de negocio',
          route: '/administrador/business-hours',
          icon: Icon(Icons.access_time, size: 90, color: Colors.black),
        ),
      ],
    );
  }
}
