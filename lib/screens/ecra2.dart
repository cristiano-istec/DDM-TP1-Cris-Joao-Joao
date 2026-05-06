import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/providers.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import 'ecra3.dart';

class Ecra2 extends ConsumerWidget {
  final int contaIndex;

  const Ecra2({super.key, required this.contaIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contas = ref.watch(contasProvider);

    if (contaIndex >= contas.length) {
      return const Scaffold(
        body: Center(child: Text("Conta não encontrada")),
      );
    }

    final conta = contas[contaIndex];

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
          ...conta.artigos.asMap().entries.map((entry) {
            final artigoIndex = entry.key;
            final artigo = entry.value;
            final atribuicoes = conta.atribuicoes[artigoIndex] ?? {};

            return NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artigo.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${artigo.preco.toStringAsFixed(2)}€ x${artigo.quantidade}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 12),

                  NeonButton(
                    text: "Dividir por todos",
                    onPressed: () {
                      ref.read(contasProvider.notifier).dividirPorTodos(
                            contaIndex,
                            artigoIndex,
                          );
                    },
                  ),

                  const SizedBox(height: 12),

                  ...conta.participantes.asMap().entries.map((pEntry) {
                    final participanteIndex = pEntry.key;
                    final participante = pEntry.value;
                    final qtd = atribuicoes[participanteIndex] ?? 0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            participante.nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            ref.read(contasProvider.notifier).setQuantidadeParticipante(
                                  contaIndex,
                                  artigoIndex,
                                  participanteIndex,
                                  qtd - 1,
                                );
                          },
                        ),

                        Text(
                          "$qtd",
                          style: const TextStyle(color: Colors.white),
                        ),

                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            ref.read(contasProvider.notifier).setQuantidadeParticipante(
                                  contaIndex,
                                  artigoIndex,
                                  participanteIndex,
                                  qtd + 1,
                                );
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          NeonButton(
            text: "CALCULAR CONTA",
            onPressed: () {
              for (int i = 0; i < conta.artigos.length; i++) {
                final artigo = conta.artigos[i];
                final atribuicoes = conta.atribuicoes[i] ?? {};

                final totalAtribuido = atribuicoes.values.fold<int>(
                  0,
                  (sum, value) => sum + value,
                );

                if (totalAtribuido != artigo.quantidade) {
                  Fluttertoast.showToast(
                    msg: "Distribua corretamente as quantidades de todos os artigos.",
                  );
                  return;
                }
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