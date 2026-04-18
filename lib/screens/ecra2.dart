import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';
import 'ecra3.dart';

import '../widgets/neon_card.dart';
import '../widgets/neon_button.dart';

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
                      ref.read(contaProvider.notifier)
                          .dividirPorTodos(i);
                    },
                    child: const Text(
                      "Dividir por todos",
                      style: TextStyle(color: Color(0xFF00FFC6)),
                    ),
                  ),

                  ...conta.participantes.asMap().entries.map((p) {
                    final selecionados = conta.atribuicoes[i] ?? [];

                    return CheckboxListTile(
                      activeColor: const Color(0xFF00FFC6),
                      title: Text(p.value.nome,
                          style: const TextStyle(color: Colors.white)),
                      value: selecionados.contains(p.key),
                      onChanged: (_) {
                        ref.read(contaProvider.notifier)
                            .toggleParticipante(i, p.key);
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
                MaterialPageRoute(builder: (_) => const Ecra3()),
              );
            },
          )
        ],
      ),
    );
  }
}