import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReprogramarTurnoScreen extends StatefulWidget {
  final String turnoId;

  const ReprogramarTurnoScreen({Key? key, required this.turnoId}) : super(key: key);

  @override
  _ReprogramarTurnoScreenState createState() => _ReprogramarTurnoScreenState();
}

class _ReprogramarTurnoScreenState extends State<ReprogramarTurnoScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

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

  Future<void> _reprogramarTurno() async {
    final DateTime ingreso = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    try {
      await FirebaseFirestore.instance
          .collection('turnos')
          .doc(widget.turnoId)
          .update({'ingreso': ingreso});

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reprogramación exitosa'),
          content: const Text('El turno fue reprogramado con éxito'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error al reprogramar el turno: $e'); 

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo reprogramar el turno. Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
    Future<void> _cancelarTurno() async {
    try {
      await FirebaseFirestore.instance
          .collection('turnos')
          .doc(widget.turnoId)
          .delete();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Turno cancelado'),
          content: const Text('El turno fue cancelado con éxito'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the main screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error al cancelar el turno: $e');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo cancelar el turno. Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reprogramar turno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Seleccionar fecha'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Seleccionar hora'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            Text(selectedTime.format(context)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reprogramarTurno,
                child: const Text('Confirmar reprogramación'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
