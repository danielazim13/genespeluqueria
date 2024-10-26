import 'package:app/entities/usuario.dart';
import 'package:app/screens/admin/metricas_screen.dart';
import 'package:app/screens/admin/usuarios/detalle_usuario_screen.dart';
import 'package:app/screens/admin/usuarios/lista_usuarios_screen.dart';
import 'package:app/screens/cliente/turnos/reprogramar_turno_screen.dart';
import 'package:go_router/go_router.dart';

// Entities
import 'package:app/entities/servicio.dart';
import 'package:app/entities/turno.dart';

// Usuario
import 'package:app/screens/usuario/login_screen.dart';
import 'package:app/screens/usuario/register_screen.dart';
import 'package:app/screens/usuario/edit_screen.dart';

// Cliente
import 'package:app/screens/cliente/home_screen.dart';
// C/Turnos
import 'package:app/screens/cliente/turnos/agregar_turno_screen.dart';
import 'package:app/screens/cliente/turnos/lista_turnos_screen.dart';

// Admin
import 'package:app/screens/admin/home_screen.dart';
// A/Turnos
import 'package:app/screens/admin/turnos/detalle_turno_screen.dart';
import 'package:app/screens/admin/turnos/lista_turnos_screen.dart';
// A/Config
import 'package:app/screens/admin/config/horarios_screen.dart';
// A/Servicios
import 'package:app/screens/admin/servicios/lista_servicios_screen.dart';
import 'package:app/screens/admin/servicios/agregar_servicio_screen.dart';
import 'package:app/screens/admin/servicios/detalle_servicio_screen.dart';
import 'package:app/screens/admin/servicios/editar_servicio_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    ...accountRoutes,
    ...clienteRoutes,
    ...adminRoutes,
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

final clienteRoutes = [
  GoRoute(
    path: '/cliente',
    builder: (context, state) => const ClienteHomeScreen(),
  ),
  GoRoute(
    path: '/cliente/turno/pedir',
    builder: (context, state) => const SolicitarTurnoScreen(),
  ),
  GoRoute(
    path: '/cliente/turno/lista',
    builder: (context, state) => const ClienteListaTurnosScreen(),
  ),
  GoRoute(
    path:'/cliente/turno/reprogramar/:turnoId',
    builder:(context, state){
      final turnoId = state.pathParameters['turnoId']!;
      return ReprogramarTurnoScreen(turnoId: turnoId);
    },
    )
];

final adminRoutes = [
  GoRoute(
    path: '/admin',
    builder: (context, state) => const AdminHomeScreen(),
  ),
  // Turnos
  GoRoute(
    path: '/admin/turnos/lista',
    builder: (context, state) => const TurnosListScreen(),
  ),
  GoRoute(
    path: '/admin/turnos/detalles',
    builder: (context, state) => TurnoDetailsScreen(turn: state.extra as Turn),
  ),
  // Usuarios
  GoRoute(
    path: '/admin/usuarios',
    builder: (context, state) => const UsuariosScreen(),
  ),
  GoRoute(
    path: '/admin/usuarios/detalles',
    builder: (context, state) => ProfileScreen(user: state.extra as Usuario),
  ),
  // Metricas
  GoRoute(
    path: '/admin/metricas',
    builder: (context, state) => const MetricasScreen(),
  ),
  // Config
  GoRoute(
    path: '/admin/config/business-hours',
    builder: (context, state) => const BusinessHoursScreen(),
  ),
  // Servicios (ABM)
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
];
