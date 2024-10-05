import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:app/core/firebase_options.dart';
import 'package:app/core/router.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: "Genes Peluqueria",
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false);
  }
}

void main() async {
  // Asegura que Firebase este inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Iniciar la aplicación
  runApp(const MainApp());
}
