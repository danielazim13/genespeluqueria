import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/usuario.dart';

class ProfileScreen extends StatefulWidget {
  final Usuario user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Usuario user;
  bool _isLoading = false;

  String? _nameError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  info(context),
                  latestTurns(context),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _editUserInfo(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: user.nombre);
    final TextEditingController phoneController =
        TextEditingController(text: user.telefono);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Editar información de usuario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        errorText: _nameError,
                        errorStyle: const TextStyle(color: Colors.red),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        errorText: _phoneError,
                        errorStyle: const TextStyle(color: Colors.red),
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            FilledButton(
              onPressed: () async {
                setState(() {
                  _nameError = nameController.text.isEmpty
                      ? 'El nombre no puede estar vacío'
                      : null;
                  _phoneError = phoneController.text.isEmpty ||
                          !RegExp(r'^\d+$').hasMatch(phoneController.text) ||
                          phoneController.text.length < 8
                      ? 'El teléfono debe ser numérico y de aunque sea 8 dígitos'
                      : null;
                });

                if (_nameError != null || _phoneError != null) {
                  return;
                }

                setState(() {
                  _isLoading = true;
                });

                try {
                  await FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(user.id)
                      .update({
                    'nombre': nameController.text,
                    'telefono': phoneController.text,
                  });

                  setState(() {
                    user = Usuario(
                      id: user.id,
                      nombre: nameController.text,
                      telefono: phoneController.text,
                      esAdmin: user.esAdmin,
                    );
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar el usuario: $e'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget info(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: const Text(
                    'Nombre',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    user.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.phone,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: const Text(
                    'Teléfono',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    user.telefono,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _editUserInfo(context),
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget latestTurns(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 20),
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Últimos Turnos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text(
                  'Corte',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  '24 de Octubre, 15:30',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _getStatusChip('Completado'),
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text(
                  'Alisado',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  '22 de Octubre, 10:00',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _getStatusChip('Cancelado'),
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text(
                  'Corte',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  '20 de Octubre, 18:45',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: _getStatusChip('Completado'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () {
          // Navigate to full turns list
          // Navigator.push(context, MaterialPageRoute(builder: (context) => TurnsListScreen()));
        },
        icon: const Icon(Icons.list),
        label: const Text('Ver Todos'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );
}

Widget _getStatusChip(String status) {
  Color chipColor;
  Color textColor;

  switch (status.toLowerCase()) {
    case 'completado':
      chipColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
      break;
    case 'cancelado':
      chipColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
      break;
    default:
      chipColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: chipColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );
}
}
