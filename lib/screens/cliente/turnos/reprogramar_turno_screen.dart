import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReprogramarTurnoScreen extends StatefulWidget {
  final String turnoId;

  const ReprogramarTurnoScreen ({Key? key, required this.turnoId}): super(key:key);

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

    if(picked != null && picked != selectedDate){
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
    if(picked !=null && picked !=selectedTime){
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _reprogramarTurno() async {
    try {
      final DateTime ingreso = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      await FirebaseFirestore.instance
          .collection('turns')
          .doc(widget.turnoId)
          .update({'ingreso': ingreso});

      Navigator.of(context).pop();
    } catch (e) {
      print('Error al reprogramar el turno: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No se pudo reprogramar el turno'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _cancelarTurno() async {
    try {
      await FirebaseFirestore.instance.collection('turns').doc(widget.turnoId).delete();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Turno cancelado'),
          content: const Text('El turno ha sido cancelado exitosamente.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); 
              },
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
          content: const Text('No se pudo cancelar el turno'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
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
        title: Text('Reprogramar turno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title:Text('Seleccionar fecha'),
              trailing: Icon(Icons.calendar_today),
              onTap: ()=> _selectDate(context),
            ),
            Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Seleccionar hora'),
              trailing: Icon(Icons.access_time),
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
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cancelarTurno,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                child: Text(
                  'Cancelar turno',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ],
        ),
        ),
    );
  }
}
