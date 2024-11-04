import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatefulWidget {
  final ValueChanged<DateTime?> onDateSelected;
  final ValueChanged<String?> onTimeSelected;

  const DateTimeSelector({
    super.key,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  _DateTimeSelectorState createState() => _DateTimeSelectorState();
}

class _DateTimeSelectorState extends State<DateTimeSelector> {
  DateTime? selectedDate;
  String? selectedHour;
  late Future<List<String>> availableTimes;
  Map<String, dynamic>? businessHours;

  final Map<String, String> _daysTranslation = {
    'Monday': 'Lunes',
    'Tuesday': 'Martes',
    'Wednesday': 'Miércoles',
    'Thursday': 'Jueves',
    'Friday': 'Viernes',
    'Saturday': 'Sábado',
    'Sunday': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    availableTimes = Future.value([]);
    _fetchBusinessHours();
  }

Future<void> _fetchBusinessHours() async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('configuration')
        .doc('businessHours')
        .get();

    if (snapshot.exists) {
      setState(() {
        businessHours = snapshot.data() as Map<String, dynamic>?;
      });
    } else {
      await _createDefaultBusinessHours();
      setState(() {
        businessHours = {
          'Monday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
          'Tuesday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
          'Wednesday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
          'Thursday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
          'Friday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
          'Saturday': {'open': false, 'openTime': null, 'closeTime': null},
          'Sunday': {'open': false, 'openTime': null, 'closeTime': null},
        };
      });
    }
  } catch (e) {
    print("Error fetching business hours: $e");
  }
}

Future<void> _createDefaultBusinessHours() async {
  try {
    await FirebaseFirestore.instance
        .collection('configuration')
        .doc('businessHours')
        .set({
      'Monday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
      'Tuesday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
      'Wednesday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
      'Thursday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
      'Friday': {'open': true, 'openTime': '08:00', 'closeTime': '18:00'},
      'Saturday': {'open': false, 'openTime': null, 'closeTime': null},
      'Sunday': {'open': false, 'openTime': null, 'closeTime': null},
    });
  } catch (e) {
    print("Error creating default business hours: $e");
  }
}

  Future<List<String>> _fetchReservedTimes(DateTime date) async {
    try {
      final reservedTurnsSnapshot = await FirebaseFirestore.instance
          .collection('turns')
          .where('ingreso', isGreaterThanOrEqualTo: date)
          .where('ingreso', isLessThan: date.add(const Duration(days: 1)))
          .get();

      final reservedTimes = reservedTurnsSnapshot.docs
          .map((doc) => doc.data())
          .where((data) =>
              data.containsKey('ingreso') && data['ingreso'] is Timestamp)
          .map<String>((data) {
        final Timestamp timestamp = data['ingreso'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();
        return DateFormat('HH:00').format(dateTime);
      }).toList();

      return reservedTimes;
    } catch (e) {
      print("Error al recuperar los horarios reservados $e");
      return [];
    }
  }

  Future<List<String>> _calculateAvailableTimes(DateTime date) async {
    if (businessHours == null) {
      return [];
    }

    String dayOfWeek = DateFormat('EEEE').format(date);
    if (!businessHours!.containsKey(dayOfWeek) ||
        !businessHours![dayOfWeek]['open']) {
      return [];
    }

    String? openTime = businessHours![dayOfWeek]['openTime'];
    String? closeTime = businessHours![dayOfWeek]['closeTime'];
    if (openTime == null || closeTime == null) {
      return [];
    }

    TimeOfDay open = _timeOfDayFromString(openTime);
    TimeOfDay close = _timeOfDayFromString(closeTime);

    final List<String> allTimes = [];
    for (int hour = open.hour; hour < close.hour; hour++) {
      allTimes.add('${hour.toString().padLeft(2, '0')}:00');
    }

    final reservedTimes = await _fetchReservedTimes(date);
    return allTimes.where((time) => !reservedTimes.contains(time)).toList();
  }

  TimeOfDay _timeOfDayFromString(String time) {
    final format = RegExp(r'(\d{2}):(\d{2})');
    final match = format.firstMatch(time);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  }

  Widget _buildSelectDate(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(selectedDate == null
              ? 'Seleccionar fecha'
              : 'Fecha seleccionada: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
          const SizedBox(width: 10), // Add some spacing
          if (businessHours != null && selectedDate != null)
            _buildBusinessHoursIndicator(selectedDate!),
        ],
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(DateTime.now().year + 1),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            selectedDate = pickedDate;
            selectedHour = null;
            availableTimes = _calculateAvailableTimes(selectedDate!);
          });
          widget.onDateSelected(selectedDate);
        }
      },
    );
  }

  Widget _buildBusinessHoursIndicator(DateTime date) {
    String dayOfWeek = DateFormat('EEEE').format(date);
    bool isOpen = businessHours![dayOfWeek]['open'];

    return isOpen
        ? const Icon(Icons.check_circle, color: Colors.green)
        : const Icon(Icons.cancel, color: Colors.red);
  }

  void _showAvailableTimesDialog(BuildContext context, List<String> times) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar hora'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: times.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(times[index]),
                  onTap: () {
                    setState(() {
                      selectedHour = times[index];
                    });
                    widget.onTimeSelected(selectedHour);
                    Navigator.pop(context); // Close the dialog
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showBusinessHoursDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: businessHours != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildBusinessHoursList(),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBusinessHoursList() {
    List<Widget> list = [];

    if (businessHours != null) {
      // Define a list of weekdays in the correct order
      List<String> weekdays = DateFormat.E().dateSymbols.WEEKDAYS;

      // Sort days of the week according to their order in weekdays list
      List<String> sortedDays =
          businessHours!.keys.where((day) => weekdays.contains(day)).toList()
            ..sort((a, b) {
              // Get the index of each day in the weekdays list
              int indexA = weekdays.indexOf(a);
              int indexB = weekdays.indexOf(b);

              // Adjust the comparison to start with Monday (index 1) instead of Sunday (index 0)
              if (indexA == 0) indexA = 7;
              if (indexB == 0) indexB = 7;

              return indexA.compareTo(indexB);
            });

      for (var day in sortedDays) {
        bool isOpen = businessHours![day]['open'] ?? false;

        String openTime = businessHours![day]['openTime'] ?? '';
        String closeTime = businessHours![day]['closeTime'] ?? '';

        String translatedDay = _daysTranslation[day] ?? day; // Traduce el día al español

        String hoursText = isOpen ? '$openTime - $closeTime' : 'CERRADO';

        list.add(ListTile(
          title: Text(
            '$translatedDay: $hoursText',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isOpen ? Colors.black : Colors.red,
            ),
          ),
        ));
      }
    } else {
      // Handle the case when businessHours is null
      list.add(const Text('Datos de horas de negocio no disponibles.'));
    }

    return list;
  }

  Widget _buildSelectHour() {
    return FutureBuilder<List<String>>(
      future: availableTimes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final availableTimes = snapshot.data ?? [];
          return ListTile(
            title: Text(selectedHour == null
                ? 'Seleccionar hora'
                : 'Hora seleccionada: $selectedHour'),
            trailing: Icon(Icons.access_time,
                color: selectedDate == null
                    ? Colors.grey
                    : Theme.of(context).iconTheme.color),
            onTap: selectedDate == null
                ? null
                : () {
                    if (availableTimes.isNotEmpty) {
                      _showAvailableTimesDialog(context, availableTimes);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No hay horas disponibles'),
                      ));
                    }
                  },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Seleccionar hora y fecha',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: false,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Horario de atención'),
              trailing: const Icon(Icons.store),
              onTap: () {
                _showBusinessHoursDialog(context);
              },
            ),
            _buildSelectDate(context),
            _buildSelectHour(),
          ],
        ),
      ],
    );
  }
}
