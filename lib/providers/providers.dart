import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/participante.dart';
import '../models/artigo.dart';

class ContasNotifier extends Notifier<List<ContaState>> {
  @override
  List<ContaState> build() {
    return [];
  }

  void adicionarConta() {
    state = [
      ...state,
      ContaState(
        participantes: [],
        artigos: [],
        quantidadeAtual: 1,
        atribuicoes: {},
      ),
    ];
  }

  void adicionarParticipante(int contaIndex, String nome) {
    final conta = state[contaIndex];

    final novaConta = conta.copyWith(
      participantes: [
        ...conta.participantes,
        Participante(nome: nome),
      ],
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void removerParticipante(int contaIndex, int index) {
    final conta = state[contaIndex];
    final novos = [...conta.participantes];
    novos.removeAt(index);

    final novaConta = conta.copyWith(participantes: novos);
    _atualizarConta(contaIndex, novaConta);
  }

  void adicionarArtigo(int contaIndex, String nome, double preco) {
    final conta = state[contaIndex];
    final novoIndex = conta.artigos.length;

    final novaConta = conta.copyWith(
      artigos: [
        ...conta.artigos,
        Artigo(
          nome: nome,
          preco: preco,
          quantidade: conta.quantidadeAtual,
        ),
      ],
      quantidadeAtual: 1,
      atribuicoes: {
        ...conta.atribuicoes,
        novoIndex: [],
      },
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void removerArtigo(int contaIndex, int index) {
    final conta = state[contaIndex];

    final novosArtigos = [...conta.artigos];
    novosArtigos.removeAt(index);

    final novasAtribuicoes = {...conta.atribuicoes};
    novasAtribuicoes.remove(index);

    final novaConta = conta.copyWith(
      artigos: novosArtigos,
      atribuicoes: novasAtribuicoes,
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void incrementarQuantidade(int contaIndex) {
    final conta = state[contaIndex];

    final novaConta = conta.copyWith(
      quantidadeAtual: conta.quantidadeAtual + 1,
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void decrementarQuantidade(int contaIndex) {
    final conta = state[contaIndex];

    if (conta.quantidadeAtual > 1) {
      final novaConta = conta.copyWith(
        quantidadeAtual: conta.quantidadeAtual - 1,
      );

      _atualizarConta(contaIndex, novaConta);
    }
  }

  void toggleParticipante(int contaIndex, int artigoIndex, int participanteIndex) {
    final conta = state[contaIndex];

    final atuais = conta.atribuicoes[artigoIndex] ?? [];
    final nova = [...atuais];

    if (nova.contains(participanteIndex)) {
      nova.remove(participanteIndex);
    } else {
      nova.add(participanteIndex);
    }

    final novaConta = conta.copyWith(
      atribuicoes: {
        ...conta.atribuicoes,
        artigoIndex: nova,
      },
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void dividirPorTodos(int contaIndex, int artigoIndex) {
    final conta = state[contaIndex];

    final todos =
        List.generate(conta.participantes.length, (i) => i);

    final novaConta = conta.copyWith(
      atribuicoes: {
        ...conta.atribuicoes,
        artigoIndex: todos,
      },
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void _atualizarConta(int index, ContaState novaConta) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) novaConta else state[i]
    ];
  }

    void criarConta() {
    state = [
      ...state,
      ContaState(
        participantes: [],
        artigos: [],
        quantidadeAtual: 1,
        atribuicoes: {},
      ),
    ];
  }

  void removerConta(int index) {
    final novas = [...state];
    novas.removeAt(index);
    state = novas;
  }
}



class ContaState {
  final List<Participante> participantes;
  final List<Artigo> artigos;
  final int quantidadeAtual;
  final Map<int, List<int>> atribuicoes;

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
    Map<int, List<int>>? atribuicoes,
  }) {
    return ContaState(
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
      quantidadeAtual: quantidadeAtual ?? this.quantidadeAtual,
      atribuicoes: atribuicoes ?? this.atribuicoes,
    );
  }
}

// 🔥 Novo provider (lista de contas)
final contasProvider =
    NotifierProvider<ContasNotifier, List<ContaState>>(
  ContasNotifier.new,
);