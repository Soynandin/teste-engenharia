class Usuario {
  String? id;
  String nome;
  String email;
  int idade;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.idade,
  });

  // Método para converter um documento do Firestore em um objeto Usuario
  factory Usuario.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Usuario(
      id: documentId,
      nome: json['nome'],
      email: json['email'],
      idade: json['idade'],
    );
  }

  // Método para converter um objeto Usuario em um mapa para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email,
      'idade': idade,
    };
  }
}
