import 'package:app/providers/change_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/Global/globals.dart' as globals;
import 'package:app/core/firebase_options.dart';
import 'package:app/core/router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
            theme: globals.changeTheme.isdarktheme
                ? ThemeData.dark()
                : ThemeData.light(),
            title: "Genes Peluquería",
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              //Locale('en')
            ],
          );
        },
      ),
    );
  }
}

void main() async {
  // Asegura que Firebase esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia la aplicación
  runApp(const MainApp());
}
