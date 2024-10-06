import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import 'package:app/entities/servicio.dart';
import 'package:app/screens/admin/servicios/detalle_servicio_screen.dart';

class ListaServiciosScreen extends StatelessWidget {
  const ListaServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        automaticallyImplyLeading: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('servicios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }

          final servicios = snapshot.data?.docs ?? [];

          if (servicios.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles'));
          }

          return ListView.builder(
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final servicioDoc = servicios[index];
              final servicio = Servicio.fromFirestore(servicioDoc);

              return GestureDetector(
                onTap: () {
                  // Navegar a la pantalla de detalles del servicio
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Podría agregarse en el router
                      builder: (context) =>
                          DetalleServicioScreen(servicio: servicio),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                servicio.nombre,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '\$${servicio.precio.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.build),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/administrador/add-servicio');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
