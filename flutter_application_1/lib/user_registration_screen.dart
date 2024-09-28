import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para criar um novo usuário
  Future<void> _registerUser() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String username = _usernameController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty && username.isNotEmpty) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Adiciona o usuário ao Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'username': username,
          'email': email,
        });

        _showMessage('Usuário cadastrado com sucesso!');
        _clearFields();
      } catch (e) {
        _showMessage('Erro ao cadastrar usuário: $e');
      }
    } else {
      _showMessage('Preencha todos os campos!');
    }
  }

  // Limpa os campos de texto
  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _usernameController.clear();
  }

  // Função para exibir uma mensagem ao usuário
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de Nome de Usuário
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nome de Usuário'),
            ),
            SizedBox(height: 16),

            // Campo de E-mail
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),

            // Campo de Senha
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 24),

            // Botão de Cadastrar
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
