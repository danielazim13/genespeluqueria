import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';

class MetricasChartsScreen extends StatefulWidget {
  const MetricasChartsScreen({super.key});
  

  @override
  _MetricasChartsScreenState createState() => _MetricasChartsScreenState();
}

class _MetricasChartsScreenState extends State<MetricasChartsScreen> {
  DateTimeRange? _selectedDateRange;
  double rango=0;

  Future<List<DChartBarDataCustom>> fetchChartData() async {
    final snapshot = await FirebaseFirestore.instance.collection('turns').get();
    List<DChartBarDataCustom> data = [];

    List<String> estados = ['Pendiente', 'Realizado', 'Confirmado'];
    List<int> estadosCont = [0, 0, 0];

    for (var doc in snapshot.docs) {
      DateTime? ingreso = doc.data().containsKey('ingreso')
          ? (doc['ingreso'] as Timestamp).toDate()
          : null;

      // Filtrar por rango de fechas si se especifica
      if (_selectedDateRange != null && ingreso != null) {
        if (ingreso.isBefore(_selectedDateRange!.start) ||
            ingreso.isAfter(_selectedDateRange!.end)) {
          continue;
        }
      }

      if (estados[0].contains(doc['estado'])) {
        estadosCont[0]++;
      } else if (estados[1].contains(doc['estado'])) {
        estadosCont[1]++;
      } else if (estados[2].contains(doc['estado'])) {
        estadosCont[2]++;
      }
    }

    for (int i = 0; i < estados.length; i++) {
      data.add(DChartBarDataCustom(
        value: estadosCont[i].toDouble(),
        label: estados[i],
      ));
    }
        rango = snapshot.size.toDouble();
    return data;
  }

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Métricas Chart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: FutureBuilder<List<DChartBarDataCustom>>(
        future: fetchChartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos'));
          } else {
            final listData = snapshot.data ?? [];
            return Card(
      color: Colors.indigo,
          child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                              //width: 360,
                              height: 360,
                              child: AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: DChartBarCustom(
                                              max: rango,
                                              showLoading: true,
                                              loadingDuration: Duration (seconds: 1),
                                              showDomainLine: true,
                                              showDomainLabel: true,
                                              showMeasureLabel: true,
                                              showMeasureLine: true,
                                              spaceDomainLinetoChart: 10,
                                              spaceMeasureLinetoChart: 10,
                                              radiusBar: const BorderRadius.only(
                                                topLeft: Radius.circular(9),
                                                topRight: Radius.circular(9),
                                              ),
                                              listData: listData,
                                            ),
                                          ),
                            ),
                  ),
        );
          }
        },
      ),
    );
  }
}
