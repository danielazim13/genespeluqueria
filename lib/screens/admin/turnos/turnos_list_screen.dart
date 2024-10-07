import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/turno.dart';
import 'package:app/widgets/turn_item.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class TurnosListScreen extends StatefulWidget {
  const TurnosListScreen({Key? key}) : super(key: key);

  @override
  _TurnosListScreenState createState() => _TurnosListScreenState();
}

class _TurnosListScreenState extends State<TurnosListScreen> {
  TurnState? selectedState;
  final List<TurnState> states = [
    TurnState('Todos', 'Todos los turnos', Icons.all_inclusive),
    TurnState('Pendiente', 'Turnos pendientes', Icons.access_time),
    TurnState('Confirmado', 'Turnos confirmados', Icons.check_circle),
    TurnState('En Progreso', 'Turnos en progreso', Icons.hourglass_bottom),
    TurnState('Realizado', 'Turnos completados', Icons.done),
    TurnState('Cancelado', 'Turnos cancelados', Icons.cancel),
  ];
  List<Turn> allTurns = [];
  bool isLoading = true;

  // Fechas para los filtros
  DateTime? startDate;
  DateTime? endDate;

  DateTime? egresoStartDate;

  bool useIngresoFilter = true;

  @override
  void initState() {
    super.initState();
    // Inicializar las fechas de filtro con una semana desde hoy
    startDate = DateTime.now();
    endDate = DateTime.now().add(Duration(days: 7));
    egresoStartDate = DateTime.now();
    /*egresoEndDate = DateTime.now().add(Duration(days: 14));*/
    _fetchTurns();
  }

  void _fetchTurns() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('turns').get();
      setState(() {
        allTurns = snapshot.docs.map((doc) => Turn.fromFirestore(doc)).toList();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately here
    }
  }

  // Método para filtrar por fechas
  List<Turn> _filterByDate(List<Turn> turns) {
    return turns.where((turn) {
      bool withinIngresoDates = true;

      if (useIngresoFilter && startDate != null) {
        withinIngresoDates =
            turn.ingreso.isAfter(startDate!);
      }

      return withinIngresoDates;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Turn> filteredTurns = selectedState != null &&
            selectedState!.value != 'Todos'
        ? allTurns.where((turn) => turn.estado == selectedState!.value).toList()
        : allTurns;

    filteredTurns = _filterByDate(filteredTurns);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turnos'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButtonFormField<TurnState>(
                  value: selectedState ??
                      states.firstWhere((state) => state.value == 'Todos'),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                    if (value!.value == 'Todos') {
                      setState(() {
                        filteredTurns = allTurns;
                      });
                    }
                  },
                  items: states.map((state) {
                    return DropdownMenuItem<TurnState>(
                      value: state,
                      child: Row(
                        children: <Widget>[
                          Icon(state.icon),
                          const SizedBox(width: 10),
                          Text(state.title),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: useIngresoFilter,
                      onChanged: (value) {
                        setState(() {
                          useIngresoFilter = value ?? true;
                        });
                      },
                    ),
                    const Text('Usar fecha de uso del servicio para filtrar'),
                  ],
                ),
                if (useIngresoFilter) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != startDate) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        child: Text(
                          'Fecha del turno: ${startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : 'Seleccione'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _ListTurnView(
                    turns: filteredTurns, actualizadoPagina: _fetchTurns),
          ),
        ],
      ),
    );
  }
}

class TurnState {
  final String value;
  final String title;
  final IconData icon;

  TurnState(this.value, this.title, this.icon);
}

class _ListTurnView extends StatelessWidget {
  final List<Turn> turns;
  final Function actualizadoPagina;

  const _ListTurnView({
    required this.turns,
    required this.actualizadoPagina,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...turns.map((turn) =>
            TurnItem(turn: turn, actualizadoPagina: actualizadoPagina)),
        if (turns.isNotEmpty) const Divider(),
      ],
    );
  }
}