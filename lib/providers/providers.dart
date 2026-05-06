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
    );
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
        ...state.atribuicoes,
        novoIndex: _criarAtribuicaoInicial(),
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

  Map<int, int> _criarAtribuicaoInicial() {
    return {
      for (int i = 0; i < state.participantes.length; i++) i: 0,
    };
  }

  void setQuantidadeParticipante(
    int artigoIndex,
    int participanteIndex,
    int quantidade,
  ) {
    if (!_indicesValidos(artigoIndex, participanteIndex)) return;

    final artigo = state.artigos[artigoIndex];
    final atribuicoesAtuais = {
      ...(state.atribuicoes[artigoIndex] ?? {}),
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
        artigoIndex: nova,
      },
    );

    _atualizarConta(contaIndex, novaConta);
  }

  bool _indicesValidos(int artigoIndex, int participanteIndex) {
    return artigoIndex >= 0 &&
        artigoIndex < state.artigos.length &&
        participanteIndex >= 0 &&
        participanteIndex < state.participantes.length;
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

    final todos =
        List.generate(conta.participantes.length, (i) => i);
  void dividirPorTodos(int artigoIndex) {
    final artigo = state.artigos[artigoIndex];

    final novoMapa = _criarDivisaoEquilibrada(
      artigo.quantidade,
      state.participantes.length,
    );

    final novaConta = conta.copyWith(
      atribuicoes: {
        ...state.atribuicoes,
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

  void incrementarQuantidadeArtigo(int indice) {
    if (indice < 0 || indice >= state.artigos.length) return;

    final novosArtigos = [...state.artigos];
    final artigoAtual = novosArtigos[indice];

    novosArtigos[indice] = Artigo(
      nome: artigoAtual.nome,
      preco: artigoAtual.preco,
      quantidade: artigoAtual.quantidade + 1,
    );

    state = state.copyWith(
      artigos: novosArtigos,
    );
  }

  void decrementarQuantidadeArtigo(int indice) {
    if (indice < 0 || indice >= state.artigos.length) return;

    final novosArtigos = [...state.artigos];
    final artigoAtual = novosArtigos[indice];

    if (artigoAtual.quantidade > 1) {
      novosArtigos[indice] = Artigo(
        nome: artigoAtual.nome,
        preco: artigoAtual.preco,
        quantidade: artigoAtual.quantidade - 1,
      );

      state = state.copyWith(
        artigos: novosArtigos,
      );
    }
  }

  // RECIBO
  void guardarRecibo(XFile imagem) {
    state = state.copyWith(
      reciboImagem: imagem,
    );
  }

  void removerRecibo() {
    state = state.copyWith(
      limparRecibo: true,
    );
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