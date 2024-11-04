import 'package:app/entities/peluquero.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// entities
import 'package:app/entities/vehicle.dart';
import 'package:app/entities/service.dart';
import 'package:app/entities/turn.dart';

// widgets
import 'package:app/widgets/spaced_column.dart';
import 'package:app/widgets/vehicle_selector.dart';
import 'package:app/widgets/service_selector.dart';
import 'package:app/widgets/date_time_selector.dart';
import 'package:app/widgets/message_form.dart';

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
  Set<Service> _selectedServices = {};
  String? _message;

  // Data
  List<Peluquero>? _peluqueros;
  List<Service>? _services;

  // Other
  late Future<void> _initialLoadFuture;

  Vehicle? _selectedVehicle;
  List<Vehicle>? _vehicles;

  // Lifecycle
  // =========
  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final vehiclesFuture = VehicleSelector.loadVehicles();
    final servicesFuture = ServiceSelector.loadServices();
    final results = await Future.wait([vehiclesFuture, servicesFuture]);

    setState(() {
      _vehicles = results[0] as List<Vehicle>;
      _services = results[1] as List<Service>;
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

    final newTurn = Turn(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        vehicleId: _selectedVehicle!.id,
        services: _selectedServices.map((service) => service.id).toList(),
        ingreso: ingreso,
        state: 'Pendiente',
        totalPrice: _getSubtotal(),
        egreso: await _getEgresoEstimado(ingreso),
        message: _message ?? '');

    try {
      await FirebaseFirestore.instance
          .collection('turns')
          .add(newTurn.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turno creado exitosamente'),
        ),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear turno'),
        ),
      );
    }
  }

  Future<DateTime> _getEgresoEstimado(DateTime ingreso) async {
    int totalDias = 0;

    // Sumar los días aproximados de cada servicio seleccionado
    for (var service in _selectedServices) {
      totalDias += service.diasAproximados;
    }

    try {
      // Recuperar la configuración de businessHours desde Firestore
      DocumentSnapshot<Map<String, dynamic>> businessHoursSnapshot =
          await FirebaseFirestore.instance
              .collection('configuration')
              .doc('businessHours')
              .get();

      Map<String, dynamic> businessHours =
          businessHoursSnapshot.data() as Map<String, dynamic>;

      DateTime egresoEstimado = ingreso;
      int diasAgregados = 0;

      // Agregar días hábiles hasta alcanzar el total de días
      while (diasAgregados < totalDias) {
        egresoEstimado = egresoEstimado.add(const Duration(days: 1));

        // Obtener el nombre del día de la semana en inglés
        String diaSemana = _getWeekdayName(egresoEstimado.weekday);

        // Verificar si el día es hábil
        if (businessHours[diaSemana]['open'] == true) {
          diasAgregados++;
        }
      }

      return egresoEstimado;
    } catch (error) {
      print("Error al obtener la configuración de businessHours: $error");
      // Manejar el error de alguna manera apropiada
      // Por ejemplo, devolver la fecha de egreso estimada sin considerar los días hábiles
      return ingreso.add(Duration(days: totalDias));
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
        VehicleSelector(
          vehicles: _vehicles!,
          onVehicleSelected: (x) => setState(() => _selectedVehicle = x),
        ),
        ServiceSelector(
          services: _services!,
          onServicesSelected: (x) => setState(() => _selectedServices = x),
        ),
        MessageForm(
          onMessageChanged: (x) => setState(() => _message = x),
        ),
        _buildSubtotal(),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildSubtotal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Precio: \$${_getSubtotal().toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Text(
            'Duración: ${_getDiasAproximados().toStringAsFixed(0)} ${_getDiasAproximados() == 1 ? 'día hábil' : 'días hábiles'}',
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
    bool isVehicleSelected = _selectedVehicle != null;
    bool isServiceSelected = _selectedServices.isNotEmpty;
    bool isDateSelected = _selectedDate != null;
    bool isHourSelected = _selectedHour != null;

    return isVehicleSelected &&
        isServiceSelected &&
        isDateSelected &&
        isHourSelected;
  }

  double _getSubtotal() {
    return _selectedServices.fold(
        0.0, (total, service) => total + service.price);
  }

  double _getDiasAproximados() {
    return _selectedServices.fold(
        0.0, (total, service) => total + service.diasAproximados);
  }

  // Método para obtener el nombre del día de la semana en inglés
  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
