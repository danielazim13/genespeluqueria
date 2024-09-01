import 'package:go_router/go_router.dart';

import 'package:aplicacion_taller/screens/auth/login_screen.dart';
import 'package:aplicacion_taller/screens/auth/register_screen.dart';

import 'package:aplicacion_taller/screens/admin/home_screen.dart';
import 'package:aplicacion_taller/screens/cliente/home_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    ...accountRoutes,
    ...adminRoutes,
    ...clienteRoutes,
  ],
);

final accountRoutes = [
  GoRoute(
    path: '/',
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) => const RegisterScreen(),
  ),
];

final adminRoutes = [
  GoRoute(
    path: '/administrador',
    builder: (context, state) => const AdminHomeScreen(),
  ),
];

final clienteRoutes = [
  GoRoute(
    path: '/cliente',
    builder: (context, state) => const ClienteHomeScreen(),
  ),
];
