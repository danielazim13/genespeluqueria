import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationButton extends StatelessWidget {
  final String text;
  final String route;
  final IconData icon;

  const NavigationButton({
    super.key,
    required this.text,
    required this.route,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
            // trailing: const Icon(Icons.arrow_forward_ios),
            leading: Icon(icon, size: 32),
            title: Text(text, style: const TextStyle(fontSize: 16)),
            onTap: () => context.push(route)));
  }
}
