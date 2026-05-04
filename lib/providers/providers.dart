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

  void removerParticipante(int indice) {
    final novosParticipantes = [...state.participantes];
    novosParticipantes.removeAt(indice);
    state = state.copyWith(participantes: novosParticipantes);
  }

  void adicionarArtigo(String nome, double preco) {
    final novoIndex = state.artigos.length;

    state = state.copyWith(
      artigos: [
        ...state.artigos,
        Artigo(nome: nome, preco: preco, quantidade: state.quantidadeAtual),
      ],
      quantidadeAtual: 1,
      atribuicoes: {
        ...state.atribuicoes,
        novoIndex: _criarAtribuicaoInicial(),
      },
    );
  }

  Map<int, int> _criarAtribuicaoInicial() {
    return {
      for (int i = 0; i < state.participantes.length; i++) i: 0,
    };
  }

  void removerArtigo(int indice) {
    final novosArtigos = [...state.artigos];
    novosArtigos.removeAt(indice);

    final novasAtribuicoes = {...state.atribuicoes};
    novasAtribuicoes.remove(indice);

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
    if (!_indicesValidos(artigoIndex, participanteIndex)) return;

    final artigo = state.artigos[artigoIndex];
    final atribuicoesAtuais = {...(state.atribuicoes[artigoIndex] ?? {})};
    final totalOutros = _totalAtribuidoSemParticipante(atribuicoesAtuais, participanteIndex);
    final quantidadeMaxima = artigo.quantidade - totalOutros;
    final quantidadeFinal = quantidade.clamp(0, quantidadeMaxima < 0 ? 0 : quantidadeMaxima).toInt();

    atribuicoesAtuais[participanteIndex] = quantidadeFinal;
    state = state.copyWith(
      atribuicoes: {
        ...state.atribuicoes,
        artigoIndex: atribuicoesAtuais,
      },
    );
  }

  bool _indicesValidos(int artigoIndex, int participanteIndex) {
    return artigoIndex >= 0 && artigoIndex < state.artigos.length &&
        participanteIndex >= 0 && participanteIndex < state.participantes.length;
  }

  int _totalAtribuidoSemParticipante(Map<int, int> atribuicoes, int participanteIndex) {
    return atribuicoes.entries
        .where((entry) => entry.key != participanteIndex)
        .fold(0, (sum, entry) => sum + entry.value);
  }

  void dividirPorTodos(int artigoIndex) {
    final artigo = state.artigos[artigoIndex];
    final novoMapa = _criarDivisaoEquilibrada(artigo.quantidade, state.participantes.length);

    state = state.copyWith(
      atribuicoes: {
        ...state.atribuicoes,
        artigoIndex: novoMapa,
      },
    );
  }

  Map<int, int> _criarDivisaoEquilibrada(int total, int participantes) {
    final mapa = <int, int>{};
    final base = participantes > 0 ? total ~/ participantes : 0;
    final resto = participantes > 0 ? total % participantes : 0;

    for (int i = 0; i < participantes; i++) {
      mapa[i] = base + (i < resto ? 1 : 0);
    }

    return mapa;
  }

  void incrementarQuantidadeArtigo(int indice) {
    if (indice >= 0 && indice < state.artigos.length) {
      final novosArtigos = [...state.artigos];
      novosArtigos[indice] = Artigo(
        nome: novosArtigos[indice].nome,
        preco: novosArtigos[indice].preco,
        quantidade: novosArtigos[indice].quantidade + 1,
      );
      state = state.copyWith(artigos: novosArtigos);
    }
  }

  void decrementarQuantidadeArtigo(int indice) {
    final novosArtigos = [...state.artigos];
    if (novosArtigos[indice].quantidade > 1) {
      novosArtigos[indice] = Artigo(
        nome: novosArtigos[indice].nome,
        preco: novosArtigos[indice].preco,
        quantidade: novosArtigos[indice].quantidade - 1,
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