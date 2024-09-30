import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/servicio.dart';
import 'package:app/entities/turno.dart';
import 'package:app/entities/usuario.dart';

class SolicitarTurnoScreen extends StatefulWidget {
  final Usuario currentUser;

  const SolicitarTurnoScreen({super.key, required this.currentUser});

  @override
  _SolicitarTurnoScreenState createState() => _SolicitarTurnoScreenState();
}

class _SolicitarTurnoScreenState extends State<SolicitarTurnoScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  List<Service> services = [];
  Map<String, bool> selectedServices = {};
  double total = 0;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() async {
    // Simulate loading services from Firestore
    // In a real app, you'd fetch this from Firestore
    services = [
      Service(id: '1', nombre: 'Peinado', precio: 500, duracion: 30),
      Service(id: '2', nombre: 'Tintura', precio: 1500, duracion: 60),
      Service(id: '3', nombre: 'Extensiones', precio: 5000, duracion: 120),
    ];
    setState(() {
      for (var service in services) {
        selectedServices[service.id] = false;
      }
    });
  }

  void _updateTotal() {
    total = services
        .where((service) => selectedServices[service.id] ?? false)
        .fold(0, (sum, service) => sum + service.precio);
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _solicitarTurno() {
    // Here you would typically save the turn to Firestore
    // For this example, we'll just print the details
    final selectedServiceIds = services
        .where((service) => selectedServices[service.id] ?? false)
        .map((service) => service.id)
        .toList();

    final turno = Turn(
      usuarioId: widget.currentUser.id,
      servicios: selectedServiceIds,
      ingreso: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
      estado: 'Pendiente',
      precio: total,
      egreso:
          DateTime.now(), // This should be calculated based on service duration
      mensaje: '',
    );

    print('Turno solicitado: ${turno.toFirestore()}');
    // Here you would save `turno` to Firestore

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Turno Solicitado'),
        content: Text('Su turno ha sido solicitado con éxito.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar turno'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Seleccionar fecha'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
              SizedBox(height: 16),
              ListTile(
                title: Text('Seleccionar hora'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              Text(selectedTime.format(context)),
              SizedBox(height: 16),
              Text('Seleccionar servicios',
                  style: Theme.of(context).textTheme.titleMedium),
              ...services.map((service) => CheckboxListTile(
                    title: Text(service.nombre),
                    subtitle: Text('\$${service.precio.toStringAsFixed(2)}'),
                    value: selectedServices[service.id] ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        selectedServices[service.id] = value ?? false;
                        _updateTotal();
                      });
                    },
                  )),
              SizedBox(height: 16),
              Text('Total: \$${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _solicitarTurno,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Solicitar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
