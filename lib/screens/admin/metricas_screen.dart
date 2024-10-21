import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MetricasScreen extends StatelessWidget {
  const MetricasScreen({super.key});

  Future<Map<String, dynamic>> obtenerDatos() async {
    try {
      QuerySnapshot turnosSnapshot =
          await FirebaseFirestore.instance.collection('turns').get();
      QuerySnapshot serviciosSnapshot =
          await FirebaseFirestore.instance.collection('servicios').get();

      // Mapear IDs de servicios a nombres
      Map<String, String> idToName = {};
      List<String> serviciosDisponibles = [];
      for (var doc in serviciosSnapshot.docs) {
        idToName[doc.id] = doc['nombre'];
        serviciosDisponibles.add(doc['nombre']);
      }

      // Mapear campos de turno y filtrar por estados permitidos
      List<Map<String, dynamic>> turnosMapeados =
          turnosSnapshot.docs.where((turnoDoc) {
        final turnoData = turnoDoc.data() as Map<String, dynamic>;
        final estado = turnoData['estado'];

        // Filtrar por los estados permitidos
        return estado == 'Confirmado' ||
            estado == 'En proceso' ||
            estado == 'Realizado';
      }).map((turnoDoc) {
        final turnoData = turnoDoc.data() as Map<String, dynamic>;

        print(turnoData);
        List<String> nombresServicios = [];
        for (var idServicio in (turnoData['services'] as List)) {
          if (idToName.containsKey(idServicio)) {
            nombresServicios.add(idToName[idServicio]!);
          }
        }

        return {
          'id': turnoDoc.id,
          'ingreso': turnoData.containsKey('ingreso')
              ? (turnoData['ingreso'] as Timestamp).toDate()
              : null,
          'egreso': turnoData.containsKey('egreso')
              ? (turnoData['egreso'] as Timestamp).toDate()
              : null,
          'services': nombresServicios,
          'mensaje': turnoData['mensaje'] ?? '',
          'estado': turnoData['estado'] ?? '',
          'precio': (turnoData['precio'] ?? 0).toDouble(),
        };
      }).toList();

      return {
        'turnos': turnosMapeados,
        'servicios': serviciosDisponibles,
      };
    } catch (e) {
      // Manejo de errores
      print('Error al obtener los datos: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métricas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: obtenerDatos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          return FiltrosYMetrica(
            turnos: snapshot.data!['turnos'],
            servicios: snapshot.data!['servicios'],
          );
        },
      ),
    );
  }
}

class FiltrosYMetrica extends StatefulWidget {
  final List<Map<String, dynamic>> turnos;
  final List<String> servicios;

  const FiltrosYMetrica({
    super.key,
    required this.turnos,
    required this.servicios,
  });

  @override
  _FiltrosYMetricaState createState() => _FiltrosYMetricaState();
}

class _FiltrosYMetricaState extends State<FiltrosYMetrica> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _selectedTipoServicio;
  List<Map<String, dynamic>> turnosFiltrados = [];

  @override
  void initState() {
    super.initState();
    turnosFiltrados = widget.turnos;
  }

  Future<void> _seleccionarFechaInicio(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        _filtrarTurnos();
      });
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaFin = picked;
        _filtrarTurnos();
      });
    }
  }

  void _filtrarTurnos() {
    setState(() {
      turnosFiltrados = widget.turnos.where((turno) {
        final ingreso = turno['ingreso'] as DateTime?;
        final egreso = turno['egreso'] as DateTime?;
        bool cumpleFecha = true;
        bool cumpleServicio = true;

        if (_fechaInicio != null && _fechaFin != null) {
          cumpleFecha = (ingreso != null &&
                  ingreso.isAfter(_fechaInicio!) &&
                  ingreso.isBefore(_fechaFin!)) ||
              (egreso != null &&
                  egreso.isAfter(_fechaInicio!) &&
                  egreso.isBefore(_fechaFin!));
        }

        if (_selectedTipoServicio != null) {
          cumpleServicio = turno['services'].contains(_selectedTipoServicio);
        }

        return cumpleFecha && cumpleServicio;
      }).toList();
    });
  }

  void _borrarFiltros() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      _selectedTipoServicio = null;
      turnosFiltrados = widget.turnos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalTurnos = turnosFiltrados.length;
    final turnosConfirmados =
        turnosFiltrados.where((t) => t['state'] == 'Confirmado').length;
    final turnosRealizados =
        turnosFiltrados.where((t) => t['state'] == 'Realizado').length;
    final totalServicios =
        turnosFiltrados.expand((t) => t['services'] as List<String>).length;
    final totalIngresos = turnosFiltrados.fold(
        0.0, (sum, turno) => sum + (turno['precio'] as double));
    final promedioIngresosPorServicio =
        totalServicios > 0 ? totalIngresos / totalServicios : 0.0;

    // Calcular tiempo promedio por servicio (en días)
    double tiempoPromedioPorServicio = 0.0;
    int cantidadTurnosRealizados = 0;

    for (var turno in turnosFiltrados) {
      if (turno['state'] == 'Realizado' &&
          turno['ingreso'] != null &&
          turno['egreso'] != null) {
        final DateTime ingreso = turno['ingreso'];
        final DateTime egreso = turno['egreso'];
        final int dias = egreso.difference(ingreso).inDays;
        tiempoPromedioPorServicio += dias;
        cantidadTurnosRealizados++;
      }
    }

    tiempoPromedioPorServicio = cantidadTurnosRealizados > 0
        ? tiempoPromedioPorServicio / cantidadTurnosRealizados
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ExpansionTile(
          title: const Text('Filtros'),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _seleccionarFechaInicio(context),
                    child: Text(_fechaInicio == null
                        ? 'Fecha inicio'
                        : DateFormat('dd/MM/yyyy').format(_fechaInicio!)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _seleccionarFechaFin(context),
                    child: Text(_fechaFin == null
                        ? 'Fecha fin'
                        : DateFormat('dd/MM/yyyy').format(_fechaFin!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTipoServicio,
                      hint: const Text('Tipo de Servicio'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTipoServicio = newValue;
                          _filtrarTurnos();
                        });
                      },
                      items: widget.servicios
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _borrarFiltros,
                    child: const Text('Borrar filtros'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _buildSection(
          icon: Icons.event,
          title: 'Turnos',
          metrics: [
            {'label': 'Total de Turnos', 'value': totalTurnos.toString()},
            {
              'label': 'Turnos Confirmados',
              'value': turnosConfirmados.toString()
            },
            {
              'label': 'Turnos Realizados',
              'value': turnosRealizados.toString()
            },
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _buildSection(
          icon: Icons.build,
          title: 'Servicios',
          metrics: [
            {'label': 'Total de Servicios', 'value': totalServicios.toString()},
            {
              'label': 'Tiempo Promedio por Servicio (días)',
              'value': tiempoPromedioPorServicio.toStringAsFixed(2)
            },
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        _buildSection(
          icon: Icons.attach_money,
          title: 'Ingresos',
          metrics: [
            {
              'label': 'Total de Ingresos',
              'value': '\$${totalIngresos.toStringAsFixed(2)}'
            },
            {
              'label': 'Promedio Ingreso por Servicio',
              'value': '\$${promedioIngresosPorServicio.toStringAsFixed(2)}'
            },
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      {required IconData icon,
      required String title,
      required List<Map<String, String>> metrics}) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          ...metrics.map(
            (metric) => ListTile(
              title: Text(metric['label']!),
              trailing: Text(
                metric['value']!,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
