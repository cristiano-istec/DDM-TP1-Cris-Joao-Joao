class Artigo {
  String nome;
  double preco;
  int quantidade;

  Artigo({
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
    };
  }

  factory Artigo.fromJson(Map<String, dynamic> json) {
    return Artigo(
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
      quantidade: json['quantidade'] as int,
    );
  }
}