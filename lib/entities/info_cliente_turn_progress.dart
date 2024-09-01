import 'package:intl/intl.dart';

class TurnDetails {
  final String userName;
  final String vehicleBrand;
  final String vehicleModel;
  final DateTime ingreso;
  final String turnState;
  final DateTime egreso;

  TurnDetails({
    required this.userName,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.ingreso,
    required this.turnState,
    required this.egreso,
  });

  String get ingresoDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(ingreso);
  }

  String get egresoDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(egreso);
  }
}
