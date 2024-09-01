import 'package:flutter/material.dart';
import 'package:aplicacion_taller/widgets/home_screen_base.dart';
import 'package:aplicacion_taller/widgets/navigation_button.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenBase(
      title: 'AutoFixer (Admin)',
      buttons: [
        NavigationButton(
          text: 'Turnos',
          route: '/administrador/turnos',
          icon: Icon(Icons.calendar_month, size: 90, color: Colors.black),
        ),
        NavigationButton(
          text: 'Usuarios',
          route: '/administrador/perfiles',
          icon: Icon(Icons.person, size: 90, color: Colors.black),
        ),
        NavigationButton(
          text: 'Metricas',
          route: '/administrador/metricas',
          icon: Icon(Icons.bar_chart, size: 90, color: Colors.black),
        ),
        NavigationButton(
          text: 'Servicios',
          route: '/administrador/servicios',
          icon: Icon(Icons.local_hospital, size: 90, color: Colors.black),
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
