import 'package:app/entities/servicio.dart';
import 'package:app/entities/usuario.dart';
import 'package:app/screens/usuario/edit_screen.dart';
import 'package:go_router/go_router.dart';

// Usuario
import 'package:app/screens/usuario/login_screen.dart';
import 'package:app/screens/usuario/register_screen.dart';
import 'package:app/screens/pedir_turno_screen.dart';

// Administrador
import 'package:app/screens/admin/home_screen.dart';
// Administrador > Servicios
import 'package:app/screens/admin/servicios/lista_servicios_screen.dart';
import 'package:app/screens/admin/servicios/agregar_servicio_screen.dart';
import 'package:app/screens/admin/servicios/detalle_servicio_screen.dart';
import 'package:app/screens/admin/servicios/editar_servicio_screen.dart';

// Administrador > Turnos
import 'package:app/screens/admin/turnos/turnos_details_screen.dart';
import 'package:app/screens/admin/turnos/turnos_list_screen.dart';

// Cliente
import 'package:app/screens/cliente_screen.dart';

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
  // Servicios
  GoRoute(
    path: '/admin/servicios/lista',
    builder: (context, state) => const ListaServiciosScreen(),
  ),
  GoRoute(
    path: '/admin/servicios/agregar',
    builder: (context, state) => const AgregarServicioScreen(),
  ),
  GoRoute(
    path: '/admin/servicios/detalle',
    builder: (context, state) =>
        DetalleServicioScreen(servicio: state.extra as Servicio),
  ),
  GoRoute(
    path: '/admin/servicios/editar',
    builder: (context, state) =>
        EditarServicioScreen(servicio: state.extra as Servicio),
  ),
    // Turnos

  /*GoRoute(
    path: '/admin/turnos/lista',
    builder: (context, state) => const ListaTurnosScreen(),
  ),
  GoRoute(
    path: '/admin/turnos/detalles',
    builder: (context, state) => const ListaDetallesScreen(),
  ),*/
];

final clienteRoutes = [
  GoRoute(
    path: '/cliente',
    builder: (context, state) => const ClienteHomeScreen(),
  ),
GoRoute(
  path: '/cliente/turno/pedir',
  builder: (context, state) {
    final Usuario? currentUser = state.extra as Usuario?; 
    return SolicitarTurnoScreen(currentUser: currentUser);
  },
),
];
