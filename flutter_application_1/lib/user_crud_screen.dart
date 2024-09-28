import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCrudScreen extends StatefulWidget {
  const UserCrudScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserCrudScreenState createState() => _UserCrudScreenState();
}

class _UserCrudScreenState extends State<UserCrudScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para criar usuário
  Future<void> _createUser() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String username = _usernameController.text;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'email': email,
      });

      _clearFields();  // Limpa os campos após a criação do usuário
      if (kDebugMode) {
        print('Usuário criado com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar usuário: $e');
      }
    }
  }

  // Função para limpar os campos
  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _usernameController.clear();
  }

  // Função para atualizar o nome do usuário
  Future<void> _updateUser(String userId) async {
    String newUsername = _usernameController.text;

    try {
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
      });
      _clearFields();
      if (kDebugMode) {
        print('Nome de usuário atualizado com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar usuário: $e');
      }
    }
  }

  // Função para deletar o usuário
  Future<void> _deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      if (kDebugMode) {
        print('Usuário deletado com sucesso!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar usuário: $e');
      }
    }
  }

  // Função para exibir os dados dos usuários
  Stream<QuerySnapshot> _getUsers() {
    return _firestore.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD de Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de Nome de Usuário
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Nome de Usuário'),
            ),
            const SizedBox(height: 16),

            // Campo de E-mail
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),

            // Campo de Senha
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Botão Criar Usuário
            ElevatedButton(
              onPressed: _createUser,
              child: const Text('Criar Usuário'),
            ),

            const SizedBox(height: 16),

            // Exibição de lista de usuários
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar usuários'));
                  }

                  final users = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user['username'] ?? ''),
                        subtitle: Text(user['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botão de atualizar usuário
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _usernameController.text = user['username'];
                                _updateUser(user.id);
                              },
                            ),
                            // Botão de deletar usuário
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteUser(user.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
