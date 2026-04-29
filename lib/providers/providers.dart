import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/participante.dart';
import '../models/artigo.dart';

class ContaNotifier extends Notifier<ContaState> {
  @override
  ContaState build() {
    return ContaState(
      participantes: [],
      artigos: [],
      quantidadeAtual: 1,
      atribuicoes: {},
    );
  }

  void adicionarParticipante(String nome) {
    state = state.copyWith(
      participantes: [
        ...state.participantes,
        Participante(nome: nome),
      ],
    );
  }

  void removerParticipante(int index) {
    final novos = [...state.participantes];
    novos.removeAt(index);
    state = state.copyWith(participantes: novos);
  }

  void adicionarArtigo(String nome, double preco) {
    final novoIndex = state.artigos.length;
    final novaAtribuicao = <int, int>{};
    
    for (int i = 0; i < state.participantes.length; i++) {
      novaAtribuicao[i] = 0;
    }

    state = state.copyWith(
      artigos: [
        ...state.artigos,
        Artigo(nome: nome, preco: preco, quantidade: state.quantidadeAtual),
      ],
      quantidadeAtual: 1,
      atribuicoes: {
        ...state.atribuicoes,
        novoIndex: novaAtribuicao,
      },
    );
  }

  void removerArtigo(int index) {
    final novosArtigos = [...state.artigos];
    novosArtigos.removeAt(index);

    final novasAtribuicoes = {...state.atribuicoes};
    novasAtribuicoes.remove(index);

    state = state.copyWith(
      artigos: novosArtigos,
      atribuicoes: novasAtribuicoes,
    );
  }

  void incrementarQuantidade() {
    state = state.copyWith(
      quantidadeAtual: state.quantidadeAtual + 1,
    );
  }

  void decrementarQuantidade() {
    if (state.quantidadeAtual > 1) {
      state = state.copyWith(
        quantidadeAtual: state.quantidadeAtual - 1,
      );
    }
  }

  void setQuantidadeParticipante(int artigoIndex, int participanteIndex, int quantidade) {
    if (artigoIndex < 0 || artigoIndex >= state.artigos.length) return;
    if (participanteIndex < 0 || participanteIndex >= state.participantes.length) return;

    final artigo = state.artigos[artigoIndex];
    final atuais = {...(state.atribuicoes[artigoIndex] ?? {})};
    final otherTotal = atuais.entries
        .where((entry) => entry.key != participanteIndex)
        .fold<int>(0, (sum, entry) => sum + entry.value);

    final maxPermitted = artigo.quantidade - otherTotal;
    final novaQuantidade = quantidade.clamp(0, maxPermitted < 0 ? 0 : maxPermitted).toInt();

    atuais[participanteIndex] = novaQuantidade;
    final novasAtribuicoes = {...state.atribuicoes, artigoIndex: atuais};

    state = state.copyWith(atribuicoes: novasAtribuicoes);
  }

  void dividirPorTodos(int artigoIndex) {
    final artigo = state.artigos[artigoIndex];
    final novasAtribuicoes = {...state.atribuicoes};
    final mapa = <int, int>{};
    
    final qtdPorPessoa = artigo.quantidade ~/ state.participantes.length;
    final resto = artigo.quantidade % state.participantes.length;
    
    for (int i = 0; i < state.participantes.length; i++) {
      mapa[i] = qtdPorPessoa + (i < resto ? 1 : 0);
    }
    
    novasAtribuicoes[artigoIndex] = mapa;
    state = state.copyWith(atribuicoes: novasAtribuicoes);
  }

  void incrementarQuantidadeArtigo(int index) {
    if (index >= 0 && index < state.artigos.length) {
      final novosArtigos = [...state.artigos];
      novosArtigos[index] = Artigo(
        nome: novosArtigos[index].nome,
        preco: novosArtigos[index].preco,
        quantidade: novosArtigos[index].quantidade + 1,
      );
      state = state.copyWith(artigos: novosArtigos);
    }
  }

  void decrementarQuantidadeArtigo(int index) {
    final novosArtigos = [...state.artigos];
    if (novosArtigos[index].quantidade > 1) {
      novosArtigos[index] = Artigo(
        nome: novosArtigos[index].nome,
        preco: novosArtigos[index].preco,
        quantidade: novosArtigos[index].quantidade - 1,
      );
      state = state.copyWith(artigos: novosArtigos);
    }
  }
}

class ContaState {
  final List<Participante> participantes;
  final List<Artigo> artigos;
  final int quantidadeAtual;
  final Map<int, Map<int, int>> atribuicoes;

  ContaState({
    required this.participantes,
    required this.artigos,
    required this.quantidadeAtual,
    required this.atribuicoes,
  });

  ContaState copyWith({
    List<Participante>? participantes,
    List<Artigo>? artigos,
    int? quantidadeAtual,
    Map<int, Map<int, int>>? atribuicoes,
  }) {
    return ContaState(
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
      quantidadeAtual: quantidadeAtual ?? this.quantidadeAtual,
      atribuicoes: atribuicoes ?? this.atribuicoes,
    );
  }
}

final contaProvider =
    NotifierProvider<ContaNotifier, ContaState>(ContaNotifier.new);