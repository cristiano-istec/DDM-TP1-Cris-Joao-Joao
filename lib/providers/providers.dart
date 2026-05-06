import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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
        id: const Uuid().v4(),
        participantes: [],
        artigos: [],
        quantidadeAtual: 1,
        atribuicoes: {},
        reciboImagem: null,
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
        novoIndex: _criarAtribuicaoInicial(conta.participantes),
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

    final atribuicoesAtuais = conta.atribuicoes[artigoIndex] ?? {};
    final novasAtribuicoes = {...atribuicoesAtuais};

    if (novasAtribuicoes.containsKey(participanteIndex) && novasAtribuicoes[participanteIndex]! > 0) {
      novasAtribuicoes[participanteIndex] = 0;
    } else {
      novasAtribuicoes[participanteIndex] = 1;
    }

    final novaConta = conta.copyWith(
      atribuicoes: {
        ...conta.atribuicoes,
        artigoIndex: novasAtribuicoes,
      },
    );

    _atualizarConta(contaIndex, novaConta);
  }

  Map<int, int> _criarAtribuicaoInicial(List<Participante> participantes) {
    return {
      for (int i = 0; i < participantes.length; i++) i: 0,
    };
  }

  void setQuantidadeParticipante(
    int contaIndex,
    int artigoIndex,
    int participanteIndex,
    int quantidade,
  ) {
    final conta = state[contaIndex];
    if (!_indicesValidos(conta, artigoIndex, participanteIndex)) return;

    final artigo = conta.artigos[artigoIndex];
    final atribuicoesAtuais = {
      ...(conta.atribuicoes[artigoIndex] ?? {}),
    };

    final totalOutros = _totalAtribuidoSemParticipante(
      atribuicoesAtuais,
      participanteIndex,
    );

    final quantidadeMaxima = artigo.quantidade - totalOutros;

    final quantidadeFinal = quantidade
        .clamp(0, quantidadeMaxima < 0 ? 0 : quantidadeMaxima)
        .toInt();

    atribuicoesAtuais[participanteIndex] = quantidadeFinal;

    final novaConta = conta.copyWith(
      atribuicoes: {
        ...conta.atribuicoes,
        artigoIndex: atribuicoesAtuais,
      },
    );

    _atualizarConta(contaIndex, novaConta);
  }

  bool _indicesValidos(ContaState conta, int artigoIndex, int participanteIndex) {
    return artigoIndex >= 0 &&
        artigoIndex < conta.artigos.length &&
        participanteIndex >= 0 &&
        participanteIndex < conta.participantes.length;
  }

  int _totalAtribuidoSemParticipante(
    Map<int, int> atribuicoes,
    int participanteIndex,
  ) {
    return atribuicoes.entries
        .where((entry) => entry.key != participanteIndex)
        .fold(0, (sum, entry) => sum + entry.value);
  }

  void dividirPorTodos(int contaIndex, int artigoIndex) {
    final conta = state[contaIndex];
    final artigo = conta.artigos[artigoIndex];

    final novoMapa = _criarDivisaoEquilibrada(
      artigo.quantidade,
      conta.participantes.length,
    );

    final novaConta = conta.copyWith(
      atribuicoes: {
        ...conta.atribuicoes,
        artigoIndex: novoMapa,
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

  void removerConta(int index) {
    final novas = [...state];
    novas.removeAt(index);
    state = novas;
  }

  void guardarRecibo(int contaIndex, XFile imagem) {
    final conta = state[contaIndex];
    final novaConta = conta.copyWith(reciboImagem: imagem);
    _atualizarConta(contaIndex, novaConta);
  }

  void removerRecibo(int contaIndex) {
    final conta = state[contaIndex];
    final novaConta = conta.copyWith(reciboImagem: null);
    _atualizarConta(contaIndex, novaConta);
  }

  Map<int, int> _criarDivisaoEquilibrada(
    int total,
    int participantes,
  ) {
    final mapa = <int, int>{};

    final base = participantes > 0 ? total ~/ participantes : 0;
    final resto = participantes > 0 ? total % participantes : 0;

    for (int i = 0; i < participantes; i++) {
      mapa[i] = base + (i < resto ? 1 : 0);
    }

    return mapa;
  }


}



class ContaState {
  final String id;
  final List<Participante> participantes;
  final List<Artigo> artigos;
  final int quantidadeAtual;
  final Map<int, Map<int, int>> atribuicoes;
  final XFile? reciboImagem;

  ContaState({
    required this.id,
    required this.participantes,
    required this.artigos,
    required this.quantidadeAtual,
    required this.atribuicoes,
    required this.reciboImagem,
  });

  ContaState copyWith({
    List<Participante>? participantes,
    List<Artigo>? artigos,
    int? quantidadeAtual,
    Map<int, Map<int, int>>? atribuicoes,
    XFile? reciboImagem,
    bool limparRecibo = false,
  }) {
    return ContaState(
      id: id,
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
      quantidadeAtual: quantidadeAtual ?? this.quantidadeAtual,
      atribuicoes: atribuicoes ?? this.atribuicoes,
      reciboImagem: limparRecibo
          ? null
          : reciboImagem ?? this.reciboImagem,
    );
  }
}

final contasProvider =
    NotifierProvider<ContasNotifier, List<ContaState>>(
  ContasNotifier.new,
);