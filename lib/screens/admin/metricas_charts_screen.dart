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

      for (var doc in snapshot.docs) {
        data.add(DChartBarDataCustom(
          value: (doc['precio'] as num).toDouble(), // Conversión a double
          label: doc['estado'],
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

class MyBarChart extends StatelessWidget {
  const MyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: FlGridData(show: true),
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.toString(),
              const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mn';
        break;
      case 1:
        text = 'Te';
        break;
      case 2:
        text = 'Wd';
        break;
      case 3:
        text = 'Tu';
        break;
      case 4:
        text = 'Fr';
        break;
      case 5:
        text = 'St';
        break;
      case 6:
        text = 'Sn';
        break;
      default:
        text = '..';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 2,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.blueAccent,
          Colors.redAccent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.bottomCenter,
      );

  List<BarChartGroupData> get barGroups => [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(toY: 8, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(toY: 10, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(toY: 15, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(toY: 18, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(toY: 5, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 5,
          barRods: [
            BarChartRodData(toY: 9, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 6,
          barRods: [
            BarChartRodData(toY: 5, gradient: _barsGradient),
          ],
          showingTooltipIndicators: [0],
        ),
      ];
}
