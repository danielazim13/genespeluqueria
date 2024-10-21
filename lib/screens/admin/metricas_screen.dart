import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      for (var doc in serviciosSnapshot.docs) {
        idToName[doc.id] = doc['nombre'];
      }

      // Mapear turnos
      List<Map<String, dynamic>> turnosMapeados = turnosSnapshot.docs.map((turnoDoc) {
        final turnoData = turnoDoc.data() as Map<String, dynamic>;

        List<String> nombresServicios = [];
        for (var idServicio in (turnoData['servicios'] as List)) {
          if (idToName.containsKey(idServicio)) {
            nombresServicios.add(idToName[idServicio]!);
          }
        }

        return {
          'id': turnoDoc.id,
          'ingreso': turnoData.containsKey('ingreso')
              ? (turnoData['ingreso'] as Timestamp).toDate()
              : null,
          'estado': turnoData['estado'] ?? '',
          'precio': (turnoData['precio'] ?? 0).toDouble(),
          'services': nombresServicios,
        };
      }).toList();

      print(turnosMapeados);
      return {
        'turnos': turnosMapeados,
      };
    } catch (e) {
      // Error handling
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

          List<Map<String, dynamic>> turnos = snapshot.data!['turnos'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                icon: Icons.event,
                title: 'Turnos',
                metrics: [
                  {'label': 'Total de Turnos', 'value': turnos.length.toString()},
                  {
                    'label': 'Turnos Confirmados',
                    'value': turnos.where((t) => t['estado'] == 'Confirmado').length.toString()
                  },
                  {
                    'label': 'Turnos Realizados',
                    'value': turnos.where((t) => t['estado'] == 'Realizado').length.toString()
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
                    'value': '\$${turnos.fold(0.0, (sum, turno) => sum + turno['precio']).toStringAsFixed(2)}'
                  },
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Map<String, String>> metrics,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          ...metrics.map(
            (metric) => ListTile(
              title: Text(metric['label']!),
              trailing: Text(
                metric['value']!,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
