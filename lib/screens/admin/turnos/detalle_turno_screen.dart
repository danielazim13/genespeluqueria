import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app/entities/turno.dart';

class TurnoDetailsScreen extends StatefulWidget {
  final Turn turn;

  const TurnoDetailsScreen({super.key, required this.turn});

  @override
  _TurnoDetailsScreenState createState() => _TurnoDetailsScreenState();
}

class _TurnoDetailsScreenState extends State<TurnoDetailsScreen> {
  late String _selectedState;
  final List<String> _states = [
    'Pendiente',
    'Confirmado',
    'En Progreso',
    'Realizado',
    'Cancelado'
  ];
  List<String> _turnServices = [];
  String? _userDetails;
  String? _hourRange;

  @override
  void initState() {
    super.initState();
    _selectedState =
        _states.contains(widget.turn.estado) ? widget.turn.estado : _states[0];
    _fetchTurnDetails();
    _fetchUserDetails();
  }

  Future<void> _fetchTurnDetails() async {
    try {
      // Fetch services directly from the turn object
      setState(() {
        _turnServices = widget.turn.servicios.map((s) => s.nombre).toList();

        // Calculate hour range
        DateTime startTime = widget.turn.ingreso;
        //DateTime endTime = startTime.add(Duration(minutes: widget.turn.duracion));
        _hourRange =
            '${DateFormat('HH:mm').format(startTime)}'; // - ${DateFormat('HH:mm').format(endTime)}';
      });
    } catch (e) {
      print('Error al obtener detalles del servicio: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.turn.usuario.id)
          .get();
      if (snapshot.exists) {
        setState(() {
          _userDetails = snapshot['nombre'] ?? 'Nombre no disponible';
        });
      }
    } catch (e) {
      print('Error al obtener detalles del usuario: $e');
    }
  }

  void _updateTurnState() async {
    try {
      await FirebaseFirestore.instance
          .collection('turns')
          .doc(widget.turn.id)
          .update({'estado': _selectedState});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado con éxito')),
      );
      context.pop();
    } catch (e) {
      print('Error al actualizar el estado del turno: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles del Turno'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildDetailRow(
                      'Fecha',
                      DateFormat('dd/MM/yyyy').format(widget.turn.ingreso),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow('Servicios', _turnServices.join(', ')),
                    const SizedBox(height: 10),
                    _buildDetailRow('Horario', _hourRange),
                    const SizedBox(height: 10),
                    _buildDetailRow('Usuario', _userDetails),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Estado:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedState,
                          items: _states.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child:
                                  Text(value, style: TextStyle(fontSize: 16)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedState = newValue!;
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          dropdownColor: Colors.white,
                          iconEnabledColor: Colors.black,
                          underline: Container(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (widget.turn.mensaje.isNotEmpty)
                      _buildDetailRow('Comentarios', widget.turn.mensaje),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _updateTurnState,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Actualizar estado'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String? detail) {
    return detail == null
        ? const CircularProgressIndicator()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$title:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          );
  }
}
