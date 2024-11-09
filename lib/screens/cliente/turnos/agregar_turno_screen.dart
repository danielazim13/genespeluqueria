import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// entities
import 'package:app/entities/usuario.dart';
import 'package:app/entities/peluquero.dart';
import 'package:app/entities/servicio.dart';
import 'package:app/entities/turno.dart';

// widgets
import 'package:app/widgets/spaced_column.dart';
import 'package:app/widgets/agregar_turno/date_time_selector.dart';
import 'package:app/widgets/agregar_turno/servicio_selector.dart';
import 'package:app/widgets/agregar_turno/peluquero_selector.dart';
import 'package:app/widgets/agregar_turno/message_form.dart';

class SolicitarTurnoScreen extends StatefulWidget {
  const SolicitarTurnoScreen({super.key});

  @override
  State<SolicitarTurnoScreen> createState() => _SolicitarTurnoScreenState();
}

class _SolicitarTurnoScreenState extends State<SolicitarTurnoScreen> {
  // State
  Peluquero? _selectedPeluquero;
  DateTime? _selectedDate;
  String? _selectedHour;
  Set<Servicio> _selectedServicios = {};
  String? _message;

  // Data
  List<Peluquero>? _peluqueros;
  List<Servicio>? _servicios;

  // Other
  late Future<void> _initialLoadFuture;

  // Lifecycle
  // =========
  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final peluquerosFuture = PeluqueroSelector.loadPeluqueros();
    final servicesFuture = ServicioSelector.loadServicios();
    final results = await Future.wait([peluquerosFuture, servicesFuture]);

    setState(() {
      _peluqueros = results[0] as List<Peluquero>;
      _servicios = results[1] as List<Servicio>;
    });
  }

  // Fetches
  // =======
  Future<void> _submitTurn() async {
    if (!_isSubmitEnabled()) return;

    final hourParts = _selectedHour!.split(':');
    final selectedHour = int.parse(hourParts[0]);
    final selectedMinute = int.parse(hourParts[1]);

    final DateTime ingreso = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      selectedHour,
      selectedMinute,
    );

    final usuarioDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    final usuario = Usuario.fromFirestore(usuarioDoc);

    final newTurn = Turn(
      usuario: usuario,
      servicios: _selectedServicios.toList(),
      ingreso: ingreso,
      estado: 'Pendiente',
      precio: _getSubtotal(),
      mensaje: _message ?? '',
    );

    try {
      await FirebaseFirestore.instance
          .collection('turns')
          .add(newTurn.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno creado exitosamente'),
        ),
      );
      // For firebase database filtering
      print(FirebaseAuth.instance.currentUser?.uid);
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear turno'),
        ),
      );
    }
  }

  // Build
  // =====
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialLoadFuture,
      builder: (context, snapshot) {
        Widget bodyWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          bodyWidget = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          bodyWidget = const Center(child: Text('Error al cargar los datos'));
        } else {
          bodyWidget = _buildMainContent();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Solicitar turno')),
          body: bodyWidget,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SpacedColumn(
      children: [
        DateTimeSelector(
          onDateSelected: (x) => setState(() => _selectedDate = x),
          onTimeSelected: (x) => setState(() => _selectedHour = x),
        ),
        ServicioSelector(
          servicios: _servicios!,
          onServiciosSelected: (x) => setState(() => _selectedServicios = x),
        ),
        // PeluqueroSelector(
        //   peluqueros: _peluqueros!,
        //   onPeluqueroSelected: (x) => setState(() => _selectedPeluquero = x),
        // ),
        MessageForm(
          onMessageChanged: (x) => setState(() => _message = x),
        ),
        _buildSubtotal(),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubtotal() {
    final subtotal = _getSubtotal();
    final minutes = _getMinutes();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtotal == 0 ? '' : '💲: ${subtotal.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Text(
            minutes == 0 ? '' : '⌚: ${minutes.toStringAsFixed(0)}\'',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitEnabled() ? _submitTurn : null,
      child: const Text('Solicitar'),
    );
  }

  // Helpers
  // =======
  bool _isSubmitEnabled() {
    bool isServicioSelected = _selectedServicios.isNotEmpty;
    bool isDateSelected = _selectedDate != null;
    bool isHourSelected = _selectedHour != null;

    return isServicioSelected && isDateSelected && isHourSelected;
  }

double _getSubtotal() {
  return _selectedServicios.fold(
      0.0, (total, service) => total + (service.precio as num).toDouble());
}

  double _getMinutes() {
    return _selectedServicios.fold(
        0.0, (total, service) => total + service.duracion);
  }
}
