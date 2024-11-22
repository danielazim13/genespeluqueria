import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/widgets/menu_item.dart';
import 'package:app/providers/change_theme_provider.dart';

class HomeScreenBase extends StatelessWidget {
  final String title;
  final List<NavigationButton> buttons;

  const HomeScreenBase({
    super.key,
    required this.title,
    required this.buttons,
  });

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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, size: 32),
          SizedBox(width: 8),
          Text(title),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          iconSize: 32,
          onPressed: () {
            context.push('/editar');
          },
        ),
        Consumer<ChangeTheme>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isdarktheme
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
                size: 32,
              ),
              onPressed: () {
                themeProvider.darktheme();
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          iconSize: 32,
          onPressed: () => _logout(context),
        )
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    context.go('/');
  }
}
