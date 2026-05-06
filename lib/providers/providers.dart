import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/artigo.dart';
import '../models/participante.dart';

class ContasNotifier extends Notifier<List<ContaState>> {
  @override
  List<ContaState> build() {
    carregarContas();
    return [];
  }

  // =========================
  // SHARED PREFERENCES
  // =========================

  Future<void> guardarContas() async {
    final prefs = await SharedPreferences.getInstance();

    final contasJson = state.map((conta) => conta.toJson()).toList();

    await prefs.setString(
      'contas',
      jsonEncode(contasJson),
    );
  }

  Future<void> carregarContas() async {
    final prefs = await SharedPreferences.getInstance();

    final dados = prefs.getString('contas');

    if (dados == null) return;

    final lista = jsonDecode(dados) as List;

    state = lista.map((json) => ContaState.fromJson(json)).toList();
  }

  // =========================
  // CONTAS
  // =========================

  void adicionarConta() {
    final numero = state.length + 1;

    state = [
      ...state,
      ContaState(
        id: const Uuid().v4(),
        nome: "Conta $numero",
        participantes: [],
        artigos: [],
        quantidadeAtual: 1,
        atribuicoes: {},
        reciboPath: null,
      ),
    ];

    guardarContas();
  }

  void editarNomeConta(int index, String novoNome) {
    if (index < 0 || index >= state.length) return;

    final conta = state[index];

    final novaConta = conta.copyWith(
      nome: novoNome,
    );

    _atualizarConta(index, novaConta);
  }

  void removerConta(int index) {
    if (index < 0 || index >= state.length) return;

    final novas = [...state];
    novas.removeAt(index);

    state = novas;

    guardarContas();
  }

  // =========================
  // PARTICIPANTES
  // =========================

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

    final novaConta = conta.copyWith(
      participantes: novos,
    );

    _atualizarConta(contaIndex, novaConta);
  }

  // =========================
  // ARTIGOS
  // =========================

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

  // =========================
  // QUANTIDADE
  // =========================

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

  // =========================
  // ATRIBUIÇÕES
  // =========================

  void toggleParticipante(
    int contaIndex,
    int artigoIndex,
    int participanteIndex,
  ) {
    final conta = state[contaIndex];

    final atribuicoesAtuais = conta.atribuicoes[artigoIndex] ?? {};
    final novasAtribuicoes = {...atribuicoesAtuais};

    if (novasAtribuicoes.containsKey(participanteIndex) &&
        novasAtribuicoes[participanteIndex]! > 0) {
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
        .clamp(
          0,
          quantidadeMaxima < 0 ? 0 : quantidadeMaxima,
        )
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

  // =========================
  // RECIBO
  // =========================

  void guardarRecibo(int contaIndex, XFile imagem) {
    final conta = state[contaIndex];

    final novaConta = conta.copyWith(
      reciboPath: imagem.path,
    );

    _atualizarConta(contaIndex, novaConta);
  }

  void removerRecibo(int contaIndex) {
    final conta = state[contaIndex];

    final novaConta = conta.copyWith(
      limparRecibo: true,
    );

    _atualizarConta(contaIndex, novaConta);
  }

  // =========================
  // HELPERS
  // =========================

  void _atualizarConta(int index, ContaState novaConta) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) novaConta else state[i],
    ];

    guardarContas();
  }

  Map<int, int> _criarAtribuicaoInicial(List<Participante> participantes) {
    return {
      for (int i = 0; i < participantes.length; i++) i: 0,
    };
  }

  bool _indicesValidos(
    ContaState conta,
    int artigoIndex,
    int participanteIndex,
  ) {
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

// =========================
// STATE
// =========================

class ContaState {
  final String id;
  final String nome;
  final List<Participante> participantes;
  final List<Artigo> artigos;
  final int quantidadeAtual;
  final Map<int, Map<int, int>> atribuicoes;
  final String? reciboPath;

  ContaState({
    required this.id,
    required this.nome,
    required this.participantes,
    required this.artigos,
    required this.quantidadeAtual,
    required this.atribuicoes,
    required this.reciboPath,
  });

  ContaState copyWith({
    String? nome,
    List<Participante>? participantes,
    List<Artigo>? artigos,
    int? quantidadeAtual,
    Map<int, Map<int, int>>? atribuicoes,
    String? reciboPath,
    bool limparRecibo = false,
  }) {
    return ContaState(
      id: id,
      nome: nome ?? this.nome,
      participantes: participantes ?? this.participantes,
      artigos: artigos ?? this.artigos,
      quantidadeAtual: quantidadeAtual ?? this.quantidadeAtual,
      atribuicoes: atribuicoes ?? this.atribuicoes,
      reciboPath: limparRecibo ? null : reciboPath ?? this.reciboPath,
    );
  }

  // =========================
  // JSON
  // =========================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'participantes': participantes.map((p) => p.toJson()).toList(),
      'artigos': artigos.map((a) => a.toJson()).toList(),
      'quantidadeAtual': quantidadeAtual,
      'atribuicoes': atribuicoes.map(
        (key, value) => MapEntry(
          key.toString(),
          value.map(
            (k, v) => MapEntry(
              k.toString(),
              v,
            ),
          ),
        ),
      ),
      'reciboPath': reciboPath,
    };
  }

  factory ContaState.fromJson(Map<String, dynamic> json) {
    return ContaState(
      id: json['id'],
      nome: json['nome'],
      participantes: (json['participantes'] as List)
          .map((p) => Participante.fromJson(p))
          .toList(),
      artigos: (json['artigos'] as List)
          .map((a) => Artigo.fromJson(a))
          .toList(),
      quantidadeAtual: json['quantidadeAtual'],
      atribuicoes: (json['atribuicoes'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          int.parse(key),
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(
              int.parse(k),
              v as int,
            ),
          ),
        ),
      ),
      reciboPath: json['reciboPath'],
    );
  }
}

final contasProvider =
    NotifierProvider<ContasNotifier, List<ContaState>>(
  ContasNotifier.new,
);