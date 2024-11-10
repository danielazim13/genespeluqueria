import 'package:flutter/material.dart';
import 'package:app/widgets/home_screen_base.dart';
import 'package:app/widgets/menu_item.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeScreenBase(
      title: 'Home',
      buttons: [
        NavigationButton(
          icon: Icons.calendar_month,
          text: 'Agenda',
          route: '/admin/turnos/lista',
        ),
        NavigationButton(
          text: 'Usuarios',
          route: '/admin/usuarios',
          icon: Icons.group,
        ),
        NavigationButton(
          text: 'Metricas',
          route: '/admin/metricas',
          icon: Icons.bar_chart,
        ),
        NavigationButton(
          text: 'Metricas Charts',
          route: '/admin/metricas-charts',
          icon: Icons.bar_chart,
        ),
        NavigationButton(
          icon: Icons.cut,
          text: 'Servicios',
          route: '/admin/servicios/lista',
        ),
        NavigationButton(
          text: 'Horario de atención',
          route: '/admin/config/business-hours',
          icon: Icons.access_time,
        ),
      ],
    );
  }
}
