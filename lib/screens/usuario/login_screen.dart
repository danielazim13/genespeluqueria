import 'package:app/entities/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// Widget de pantalla de inicio de sesión.
/// Utiliza un StatefulWidget para manejar el estado interno.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto de email y contraseña
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instancia de FirebaseAuth y FirebaseStore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable para almacenar mensajes de error
  String _errorMessage = '';

  /// Método principal para manejar el proceso de inicio de sesión
  Future<void> _login() async {
    setState(() => _errorMessage = '');

    if (!_validateInputs()) return;

    try {
      await _authenticateUser();
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    }
  }

  /// Valida los campos de entrada antes de intentar la autenticación
  bool _validateInputs() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _setErrorMessage('Por favor llena los campos');
      return false;
    }

    // Validación simple de formato de email
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      _setErrorMessage('Email inválido');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _setErrorMessage('La contraseña debe contener al menos 6 caracteres');
      return false;
    }

    return true;
  }

  /// Autentica al usuario usando Firebase y redirige según el tipo de usuario
  Future<void> _authenticateUser() async {
    // Autenticar con Firebase Auth
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );

    final user = userCredential.user;
    if (user != null) {
      // Buscar datos adicionales del usuario en Firestore
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('usuarios').doc(user.uid).get();

        if (userDoc.exists) {
          Usuario usuario = Usuario.fromFirestore(userDoc);

          // Redirigir basado en el campo esAdmin
          if (usuario.esAdmin) {
            context.go('/admin');
          } else {
            context.go('/cliente');
          }
        } else {
          // Si el documento del usuario no existe en Firestore
          _setErrorMessage('Error: Datos de usuario no encontrados');
        }
      } catch (e) {
        // Error al obtener datos de Firestore
        _setErrorMessage('Error al obtener datos de usuario: $e');
      }
    } else {
      // Si la autenticación fue exitosa pero user es null (caso poco probable)
      _setErrorMessage('Error de autenticación');
    }
  }

  /// Maneja los errores de autenticación de Firebase
  void _handleAuthError(FirebaseAuthException e) {
    setState(() {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          _errorMessage = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          _errorMessage = 'Email inválido';
          break;
        default:
          if (e.message != null &&
              e.message!.contains(
                  'The supplied auth credential is incorrect, malformed or has expired')) {
            _errorMessage = 'Credenciales incorrectas o mal formadas';
          } else {
            _errorMessage = 'Ocurrio un error: ${e.message}';
          }
          break;
      }
    });
  }

  /// Actualiza el mensaje de error y provoca un rebuild del widget
  void _setErrorMessage(String message) {
    setState(() => _errorMessage = message);
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
                _buildLogo(),
                const SizedBox(height: 32.0),
                _buildEmailField(),
                const SizedBox(height: 16.0),
                _buildPasswordField(),
                const SizedBox(height: 16.0),
                _buildLoginButton(),
                const SizedBox(height: 16.0),
                _buildErrorMessage(),
                const SizedBox(height: 16.0),
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el widget del logo
  Widget _buildLogo() {
    return ClipOval(
      child: Image.asset(
        'lib/assets/logo.jpg',
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  /// Construye el campo de entrada para el email
  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email),
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  /// Construye el campo de entrada para la contraseña
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        labelText: 'Contraseña',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      obscureText: true,
    );
  }

  /// Construye el botón de inicio de sesión
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text('Ingresar'),
    );
  }

  /// Construye el widget para mostrar mensajes de error
  Widget _buildErrorMessage() {
    return Visibility(
      visible: _errorMessage.isNotEmpty,
      child: Text(
        _errorMessage,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  /// Construye el botón para ir a la pantalla de registro
  Widget _buildRegisterButton() {
    return TextButton(
      onPressed: () => context.push('/register'),
      child: const Text(
        '¿No tienes una cuenta? Regístrate aquí',
        style: TextStyle(color: Colors.blueAccent),
      ),
    );
  }
}
