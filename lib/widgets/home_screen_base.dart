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
      automaticallyImplyLeading: true,
      // izquierda
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, size: 36),
          SizedBox(width: 8),
          Text(title),
        ],
      ),
      // derecha
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          iconSize: 36,
          onPressed: () {
            context.push('/editar');
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          iconSize: 36,
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
            return button;
          }).toList(),
        ),
      ),
    );
  }
}
