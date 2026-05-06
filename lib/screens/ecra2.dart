import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'ecra3.dart';

import '../widgets/neon_card.dart';
import '../widgets/neon_button.dart';

class Ecra2 extends ConsumerWidget {
  final int contaIndex;

  const Ecra2({super.key, required this.contaIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contasProvider)[contaIndex];

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
                    child: const Text(
                      "Dividir por todos",
                      style: TextStyle(color: Color(0xFF00FFC6)),
                    ),
                  ),

                  // seleção de participantes
                  ...conta.participantes.asMap().entries.map((p) {
                    final selecionados = conta.atribuicoes[i] ?? [];

                    return CheckboxListTile(
                      activeColor: const Color(0xFF00FFC6),

                      title: Text(p.value.nome,
                          style: const TextStyle(color: Colors.white)),

                      value: selecionados.contains(p.key),

                      onChanged: (_) {
                        ref.read(contasProvider.notifier)
                            .toggleParticipante(contaIndex, i, p.key); 
                      },
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