import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Crea controladores de texto para los campos de correo y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Crea una instancia de FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crea una variable para manejar el estado de la autenticación
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      setState(() {
        _errorMessage = '';
      });
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Por favor llena los campos';
        });
        return;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
        setState(() {
          _errorMessage = 'Email invalido';
        });
        return;
      }

      if (_passwordController.text.length < 6) {
        setState(() {
          _errorMessage = 'La contraseña debe contener aunque sea 6 caracteres';
        });
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = userCredential.user;
      if (user != null && user.email == 'admin@example.com') {
        context.go('/administrador');
      } else {
        context.go('/cliente');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'Usuario no encontrado';
            break;
          case 'wrong-password':
            _errorMessage = 'Contraseña incorrecta';
            break;
          case 'invalid-email':
            _errorMessage = 'Email invalido';
            break;
          default:
            if (e.message != null && e.message!.contains('The supplied auth credential is incorrect, malformed or has expired')) {
              _errorMessage = 'Credenciales incorrectas o mal formadas';
            } else {
              _errorMessage = 'Ocurrio un error: ${e.message}';
            }
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Image
                ClipOval(
                  child: Image.asset(
                    'lib/assets/logo.jpg',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 32.0),
                // Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Password Field
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                // Login Button
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Logueate'),
                ),
                const SizedBox(height: 16.0),
                // Error Message
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16.0),
                // Register Text Button
                TextButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  child: const Text(
                    'No tenes una cuenta? registrate acá',
                    style: TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
