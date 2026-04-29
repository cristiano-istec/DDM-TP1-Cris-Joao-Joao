import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'ecra3.dart';

import '../widgets/neon_card.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_circle_button.dart';

class Ecra2 extends ConsumerWidget {
  const Ecra2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);

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
            final totalAtribuido = atribuicoes.values.fold<int>(0, (sum, value) => sum + value);
            final podeAdicionar = totalAtribuido < artigo.quantidade;

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
                      ref.read(contaProvider.notifier)
                          .dividirPorTodos(i);
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

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(participante.nome,
                              style: const TextStyle(color: Colors.white)),
                          Row(
                            children: [
                              NeonCircleButton(
                                icon: Icons.remove,
                                color: const Color(0xFF8B00FF),
                                onPressed: () {
                                  if (qtdAtribuida > 0) {
                                    ref.read(contaProvider.notifier)
                                        .setQuantidadeParticipante(i, participanteIndex, qtdAtribuida - 1);
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "$qtdAtribuida",
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(width: 12),
                              NeonCircleButton(
                                icon: Icons.add,
                                color: const Color(0xFF00FFC6),
                                onPressed: podeAdicionar
                                    ? () {
                                        ref.read(contaProvider.notifier)
                                            .setQuantidadeParticipante(i, participanteIndex, qtdAtribuida + 1);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                ],
              ),
            );
          }),

          NeonButton(
            text: "CALCULAR",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Ecra3()),
              );
            },
          ),
        ],
      ),
    );
  }
}