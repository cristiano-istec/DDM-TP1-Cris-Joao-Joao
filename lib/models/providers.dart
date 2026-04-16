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
      atribuicoes: {}, // 👈 ADICIONADO
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

  void adicionarArtigo(String nome, double preco) {
    final novoIndex = state.artigos.length; // 👈 ADICIONADO

    state = state.copyWith(
      artigos: [
        ...state.artigos,
        Artigo(
          nome: nome,
          preco: preco,
          quantidade: state.quantidadeAtual,
        ),
      ],
      quantidadeAtual: 1,
      atribuicoes: {
        ...state.atribuicoes,
        novoIndex: [], // 👈 ADICIONADO
      },
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

  // =========================
  // 👇 ADICIONADO PARA ECRÃ 2
  // =========================

  void toggleParticipante(int artigoIndex, int participanteIndex) {
    final atuais = state.atribuicoes[artigoIndex] ?? [];

    final novaLista = [...atuais];

    if (novaLista.contains(participanteIndex)) {
      novaLista.remove(participanteIndex);
    } else {
      novaLista.add(participanteIndex);
    }

    state = state.copyWith(
      atribuicoes: {
        ...state.atribuicoes,
        artigoIndex: novaLista,
      },
    );
  }

  void dividirPorTodos(int artigoIndex) {
    final todos =
        List.generate(state.participantes.length, (i) => i);

    state = state.copyWith(
      atribuicoes: {
        ...state.atribuicoes,
        artigoIndex: todos,
      },
    );
  }
}

// estado
class ContaState {
  final List<Participante> participantes;
  final List<Artigo> artigos;
  final int quantidadeAtual;

  // 👇 ADICIONADO
  final Map<int, List<int>> atribuicoes;

  ContaState({
    required this.participantes,
    required this.artigos,
    required this.quantidadeAtual,
    required this.atribuicoes, // 👈 ADICIONADO
  });

  ContaState copyWith({
    List<Participante>? participantes,
    List<Artigo>? artigos,
    int? quantidadeAtual,
    Map<int, List<int>>? atribuicoes, // 👈 ADICIONADO
  }) {
    return ContaState(
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
      quantidadeAtual: quantidadeAtual ?? this.quantidadeAtual,
      atribuicoes: atribuicoes ?? this.atribuicoes, // 👈 ADICIONADO
    );
  }
}

final contaProvider =
    NotifierProvider<ContaNotifier, ContaState>(ContaNotifier.new);