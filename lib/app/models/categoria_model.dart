class CategoriaModel {
  const CategoriaModel({required this.id, required this.nome});

  final String id;
  final String nome;

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
    );
  }
}
