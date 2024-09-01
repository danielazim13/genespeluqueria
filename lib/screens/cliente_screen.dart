import 'package:flutter/material.dart';
import 'package:app/widgets/home_screen_base.dart';
import 'package:app/widgets/navigation_button.dart';

class ClienteHomeScreen extends StatelessWidget {
  const ClienteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeScreenBase(
        title: 'Cliente',
        buttons: [
          NavigationButton(
            text: 'Solicitar turno',
            route: '/cliente/turno/pedir',
            icon: Icon(Icons.calendar_month, size: 90, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
