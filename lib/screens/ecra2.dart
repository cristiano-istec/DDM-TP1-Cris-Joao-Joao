import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';
import 'ecra3.dart';

class Ecra2 extends ConsumerWidget {
  const Ecra2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dividir Conta"),
      ),
      body: ListView(
        children: [
          ...conta.artigos.asMap().entries.map((entry) {
            final index = entry.key;
            final artigo = entry.value;
            final selecionados = conta.atribuicoes[index] ?? [];

            return Card(
              margin: const EdgeInsets.all(10),
              child: ExpansionTile(
                title: Text(artigo.nome),
                subtitle: Text(
                    "${artigo.preco.toStringAsFixed(2)}€ x${artigo.quantidade}"),
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(contaProvider.notifier)
                          .dividirPorTodos(index);
                    },
                    child: const Text("Dividir por todos"),
                  ),

                  ...conta.participantes.asMap().entries.map((pEntry) {
                    final pIndex = pEntry.key;
                    final participante = pEntry.value;

                    return CheckboxListTile(
                      title: Text(participante.nome),
                      value: selecionados.contains(pIndex),
                      onChanged: (_) {
                        ref.read(contaProvider.notifier)
                            .toggleParticipante(index, pIndex);
                      },
                    );
                  }),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                bool valido = true;

                for (int i = 0; i < conta.artigos.length; i++) {
                  if ((conta.atribuicoes[i] ?? []).isEmpty) {
                    valido = false;
                    break;
                  }
                }

                if (!valido) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Todos os artigos devem ter pelo menos 1 participante"),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Ecra3()),
                );
              },
              child: const Text("Calcular Conta"),
            ),
          ),
        ],
      ),
    );
  }
}