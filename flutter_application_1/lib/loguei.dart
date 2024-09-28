import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getUserData() async {
    // Obtém o ID do usuário autenticado
    User? user = _auth.currentUser;
    print('Usuário autenticado: ${user != null ? user.uid : "Nenhum usuário"}'); // Verifica se há um usuário autenticado

    if (user != null) {
      try {
        // Tenta buscar os dados do usuário no Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuario')  // Coleção correta
            .doc(user.uid)  // ID do usuário no Firestore
            .get();

        // Verifica se o documento existe
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        } else {
          throw Exception("Documento do usuário não encontrado");
        }
      } catch (e) {
        if (e is FirebaseException && e.code == 'permission-denied') {
          throw Exception("Permissões insuficientes para acessar os dados do usuário.");
        } else {
          throw Exception("Erro ao buscar os dados do Firestore: ${e.toString()}");
        }
      }
    }
    throw Exception("Usuário não autenticado");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações do Usuário'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Tratamento de erro para permissão negada
            String errorMsg = snapshot.error.toString();
            if (errorMsg.contains('permission-denied')) {
              return Center(child: Text('Permissão negada: Você não tem acesso a esses dados.'));
            } else {
              return Center(child: Text('Erro ao carregar os dados: ${snapshot.error}'));
            }
          }
          if (snapshot.hasData) {
            var userData = snapshot.data!;

            // Exibição dos dados permitidos
            String nome = userData.containsKey('nome') ? userData['nome'] : 'Nome não disponível';
            String idade = userData.containsKey('idade') ? userData['idade'].toString() : 'Idade não disponível';
            String email = userData.containsKey('email') ? userData['email'] : 'Email não disponível';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícone e nome do usuário
                  ListTile(
                    leading: Icon(Icons.person, size: 40),
                    title: Text(
                      'Nome:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      nome,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Ícone e idade do usuário
                  ListTile(
                    leading: Icon(Icons.cake, size: 40),
                    title: Text(
                      'Idade:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      idade,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Ícone e email do usuário
                  ListTile(
                    leading: Icon(Icons.email, size: 40),
                    title: Text(
                      'Email:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      email,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Dados do usuário não encontrados'));
        },
      ),
    );
  }
}
