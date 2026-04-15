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
}

// estado
class ContaState {
  final List<Participante> participantes;
  final List<Artigo> artigos;
  final int quantidadeAtual;

  ContaState({
    required this.participantes,
    required this.artigos,
    required this.quantidadeAtual,
  });

  ContaState copyWith({
    List<Participante>? participantes,
    List<Artigo>? artigos,
    int? quantidadeAtual,
  }) {
    return ContaState(
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
      quantidadeAtual: quantidadeAtual ?? this.quantidadeAtual,
    );
  }
}

final contaProvider =
    NotifierProvider<ContaNotifier, ContaState>(ContaNotifier.new);