import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';

class Ecra2 extends ConsumerWidget {
  const Ecra2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);

    final participantes = conta.participantes;
    final artigos = conta.artigos;
    final atribuicoes = conta.atribuicoes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dividir Conta"),
      ),
      body: ListView(
        children: artigos.asMap().entries.map((entry) {
          final index = entry.key;
          final artigo = entry.value;

          final selecionados = atribuicoes[index] ?? [];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text(artigo.nome),
              subtitle: Text(
                "${artigo.preco.toStringAsFixed(2)}€ x${artigo.quantidade}",
              ),
              children: [
                // ✅ BOTÃO dividir por todos
                TextButton(
                  onPressed: () {
                    ref.read(contaProvider.notifier)
                      .dividirPorTodos(index);
                  },
                  child: const Text("Dividir por todos"),
                ),

                // ✅ CHECKBOXES participantes
                ...participantes.asMap().entries.map((pEntry) {
                  final pIndex = pEntry.key;
                  final participante = pEntry.value;

                  final isSelected = selecionados.contains(pIndex);

                  return CheckboxListTile(
                    title: Text(participante.nome),
                    value: isSelected,
                    onChanged: (value) {
                      ref.read(contaProvider.notifier)
                        .toggleParticipante(index, pIndex);
                    },
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}