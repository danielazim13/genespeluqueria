import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:d_chart/d_chart.dart';

class MetricasChartsScreen extends StatelessWidget {
  const MetricasChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<DChartBarDataCustom>> fetchChartData() async {
      final snapshot =
          await FirebaseFirestore.instance.collection('turns').get();
      List<DChartBarDataCustom> data = [];

      List<String> estados = ['Pendiente','Realizado','Confirmado'];
            List<int> estadosCont = [0,0,0];
             

            for (var doc in snapshot.docs) {

               if ( estados[0].contains(doc['estado'])){
                  estadosCont[0]++;
               } else if ( estados[1].contains(doc['estado'])){
                  estadosCont[1]++;
               } else if ( estados[2].contains(doc['estado'])){
                  estadosCont[2]++;
               }           
            }

          for (int i = 0; i < estados.length; i++) {
               data.add(DChartBarDataCustom(
                value: estadosCont[i].toDouble(), 
                label: estados[i],    
              ));
            }


      return data;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Métricas Chart"),
      ),
      body: FutureBuilder<List<DChartBarDataCustom>>(
        future: fetchChartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final listData = snapshot.data ?? [];
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartBarCustom(
                max: 80000,
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
            );
          }
        },
      ),
    );
  }
}
