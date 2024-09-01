import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:app/widgets/navigation_button.dart';

class HomeScreenBase extends StatelessWidget {
  final String title;
  final List<NavigationButton> buttons;

  const HomeScreenBase({
    super.key,
    required this.title,
    required this.buttons,
  });

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    context.go('/');
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
     title: Text(
        title,
        textAlign: TextAlign.center, // Centra el texto horizontalmente
        style: const TextStyle(
          fontSize: 24, // Tamaño de la fuente más grande
          fontWeight: FontWeight.bold, // Texto en negrita
        ),
      ),
      automaticallyImplyLeading: true,
      actions: [
        IconButton(
            icon: const Icon(
              Icons.person,
            ),
             iconSize: 42,
            onPressed: () {
              context.push('/editar');
              // Acción del botón de usuario
            }),
        IconButton(
          icon: const Icon(Icons.logout),
           iconSize: 42,
          onPressed: () => _logout(context),
        )
      ],
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: buttons.map((button) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 220, // Altura fija para cada botón
                child: button,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
