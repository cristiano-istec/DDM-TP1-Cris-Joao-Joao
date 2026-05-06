import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/providers.dart';
import 'ecra3.dart';

import '../widgets/neon_card.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_circle_button.dart';

class Ecra2 extends ConsumerWidget {
  final int contaIndex;

  const Ecra2({super.key, required this.contaIndex});

  int _somarValores(Iterable<int> valores) {
    return valores.fold<int>(0, (soma, valor) => soma + valor);
  }

  int _totalAtribuidoArtigo(Map<int, int> atribuicoes) {
    return _somarValores(atribuicoes.values);
  }

  int _totalQuantidadeArtigos(ContaState conta) {
    return conta.artigos.fold<int>(0, (soma, artigo) => soma + artigo.quantidade);
  }

  int _totalQuantidadeAtribuida(ContaState conta) {
    return conta.atribuicoes.values.fold<int>(
      0,
      (soma, atribuicao) => soma + _totalAtribuidoArtigo(atribuicao),
    );
  }

  void _mostrarToastAtribuicaoPendente() {
    Fluttertoast.showToast(
      msg: "Atribua todos os artigos antes de calcular.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  Widget _construirLinhaParticipante(
    WidgetRef ref,
    int contaIndex,
    int indiceArtigo,
    int indiceParticipante,
    String nomeParticipante,
    int quantidadeAtual,
    bool podeAumentar,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nomeParticipante, style: const TextStyle(color: Colors.white)),
          Row(
            children: [
              NeonCircleButton(
                icon: Icons.remove,
                color: const Color(0xFF8B00FF),
                onPressed: quantidadeAtual > 0
                    ? () {
                        ref.read(contasProvider.notifier).setQuantidadeParticipante(
                              contaIndex,
                              indiceArtigo,
                              indiceParticipante,
                              quantidadeAtual - 1,
                            );
                      }
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                "$quantidadeAtual",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 12),
              NeonCircleButton(
                icon: Icons.add,
                color: const Color(0xFF00FFC6),
                onPressed: podeAumentar
                    ? () {
                        ref.read(contasProvider.notifier).setQuantidadeParticipante(
                              contaIndex,
                              indiceArtigo,
                              indiceParticipante,
                              quantidadeAtual + 1,
                            );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contasProvider)[contaIndex];
    final totalArtigos = _totalQuantidadeArtigos(conta);
    final totalAtribuido = _totalQuantidadeAtribuida(conta);


    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        title: const Text("Dividir Conta"),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // lista de artigos para atribuição
          ...conta.artigos.asMap().entries.map((entry) {
            final i = entry.key;
            final artigo = entry.value;
            final atribuicoes = conta.atribuicoes[i] ?? {};
            final totalAtribuidoArtigo = _totalAtribuidoArtigo(atribuicoes);
            final podeAdicionar = totalAtribuidoArtigo < artigo.quantidade;

            return NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(artigo.nome,
                      style: const TextStyle(color: Colors.white)),

                  Text("${artigo.preco}€ x${artigo.quantidade}",
                      style: const TextStyle(color: Colors.grey)),

                  TextButton(
                    onPressed: () {
                      ref.read(contasProvider.notifier)
                          .dividirPorTodos(contaIndex, i);
                    },
                    child: Text(
                      "Dividir por todos",
                      style: const TextStyle(color: Color(0xFF00FFC6)),
                    ),
                  ),

                  // Atribuição de quantidade por participante
                  ...conta.participantes.asMap().entries.map((p) {
                    final participanteIndex = p.key;
                    final participante = p.value;
                    final qtdAtribuida = conta.atribuicoes[i]?[participanteIndex] ?? 0;

                    return _construirLinhaParticipante(
                      ref,
                      contaIndex,
                      i,
                      participanteIndex,
                      participante.nome,
                      qtdAtribuida,
                      podeAdicionar,
                    );
                  }),

                ],
              ),
            );
          }),

          NeonButton(
            text: "CALCULAR",
            onPressed: () {
              if (totalArtigos != totalAtribuido) {
                _mostrarToastAtribuicaoPendente();
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Ecra3(contaIndex: contaIndex),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}