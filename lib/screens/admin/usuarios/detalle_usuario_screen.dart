import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/entities/usuario.dart';
import 'package:go_router/go_router.dart';

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

  void _editUserInfo(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: user.nombre);
    final TextEditingController phoneController =
        TextEditingController(text: user.telefono);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar información de usuario'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      errorText: _nameError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      errorText: _phoneError,
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
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
                        esAdmin: user.esAdmin);
                  });

                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar el usuario: $e'),
                    ),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil: ${user.nombre}'),
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Perfil:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('Nombre: ${user.nombre}'),
                    subtitle: Text('Teléfono: ${user.telefono}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editUserInfo(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    context.push('/admin/turno/lista/${user.id}');
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Ver Turnos'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
