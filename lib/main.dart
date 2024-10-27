import 'package:app/providers/change_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/Global/globals.dart' as globals;
import 'package:app/core/firebase_options.dart';
import 'package:app/core/router.dart';
import 'package:provider/provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChangeTheme()),
      ],
      child: Builder(
        builder: (context) {
          globals.changeTheme = Provider.of<ChangeTheme>(context);
          globals.context = context;
          return MaterialApp.router(
              theme: globals.changeTheme.isdarktheme ? ThemeData.dark() : ThemeData.light(),
              title: "Genes Peluqueria",
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false);
        }
      ),
    );
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
