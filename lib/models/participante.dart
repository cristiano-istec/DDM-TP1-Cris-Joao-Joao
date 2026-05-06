class Participante {
  String nome;

  Participante({
    required this.nome,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }

  factory Participante.fromJson(Map<String, dynamic> json) {
    return Participante(
      nome: json['nome'],
    );
  }
}