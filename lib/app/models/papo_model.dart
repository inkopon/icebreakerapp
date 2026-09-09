class PapoModel {
  const PapoModel({
    required this.id,
    required this.assunto,
    required this.categoria,
  });

  final String id;
  final String assunto;
  final String categoria;

  factory PapoModel.fromMap(Map<String, dynamic> map) {
    return PapoModel(
      id: map['id']?.toString() ?? '',
      assunto: map['assunto']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
    );
  }
}
