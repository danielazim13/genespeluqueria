import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app/entities/turn.dart';

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
  String? _turnService; //Cual servicio de los que ofrece la peluqueria quiere??
  String? _userDetails;

  @override
  void initState() {
    super.initState();
    _selectedState =
        _states.contains(widget.turn.state) ? widget.turn.state : _states[0];
    _fetchTurnDetails();
    _fetchUserDetails();
  }

  Future<void> _fetchTurnDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('turnos')
          .doc(widget.turn.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _turnService = snapshot['service'];
        });
      }
    } catch (e) {
      print('Error al obtener detalles del servicio: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.turn.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          _userDetails = snapshot['name'] ?? 'Nombre no disponible';
        });
      }
    } catch (e) {
      print('Error al obtener detalles del usuario: $e');
    }
  }

  void _updateTurnState() async {
    try {
      await FirebaseFirestore.instance
          .collection('turnos')
          .doc(widget.turn.id)
          .update({'state': _selectedState});
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
                    _buildDetailRow('Nombre del servicio', _turnService),
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
                    if (widget.turn.message.isNotEmpty)
                      _buildDetailRow('Comentarios', widget.turn.message),
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