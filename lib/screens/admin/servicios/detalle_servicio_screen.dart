import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:app/entities/servicio.dart';
import 'package:app/screens/admin/servicios/editar_servicio_screen.dart';

class DetalleServicioScreen extends StatefulWidget {
  final Servicio servicio;

  const DetalleServicioScreen({required this.servicio});

  @override
  _DetalleServicioScreenState createState() => _DetalleServicioScreenState();
}

class _DetalleServicioScreenState extends State<DetalleServicioScreen> {

  Future<Servicio> _fetchServicio() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('servicios')
        .doc(widget.servicio.id)
        .get();
    return Servicio.fromFirestore(doc);
  }

  Future<void> eliminarServicio(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('servicios')
          .doc(widget.servicio.id)
          .delete();
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el servicio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de servicio'),
      ),
      body: FutureBuilder<Servicio>(
        future: _fetchServicio(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error al traer los detalles del servicio'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Servicio no encontrado'));
          }

          Servicio servicio = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Servicio',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          )),
                      Text(
                        'Nombre servicio: ${servicio.nombre}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Precio: \$${servicio.precio.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duracion: ${servicio.duracion}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // podria agregarse en el router
                                  builder: (context) =>
                                      EditarServicioScreen(servicio: servicio),
                                ),
                              );
                            },
                            child: const Text('Editar'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              // Mostrar diálogo de confirmación
                              bool confirmacion = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: const Text(
                                        '¿Estás seguro que deseas eliminar este servicio?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmacion) {
                                // ignore: use_build_context_synchronously
                                await eliminarServicio(context);
                              }
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
