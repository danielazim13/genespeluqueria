import 'package:app/screens/usuario/edit_screen.dart';
import 'package:go_router/go_router.dart';

import 'package:app/screens/usuario/login_screen.dart';
import 'package:app/screens/usuario/register_screen.dart';

import 'package:app/screens/admin_screen.dart';
import 'package:app/screens/cliente_screen.dart';
//import 'package:app/screens/pedir_turno_screen.dart';

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
  GoRoute(
    path: '/editar',
    builder: (context, state) => const EditUserScreen(),
  ),
];

final adminRoutes = [
  GoRoute(
    path: '/admin',
    builder: (context, state) => const AdminHomeScreen(),
  ),
];

final clienteRoutes = [
  GoRoute(
    path: '/cliente',
    builder: (context, state) => const ClienteHomeScreen(),
  ),
  //GoRoute(
  //  path: '/cliente/turno/pedir',
  //  builder: (context, state) => const SolicitarTurnoScreen(),
  //),
];
