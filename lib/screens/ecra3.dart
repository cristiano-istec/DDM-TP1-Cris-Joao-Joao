import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';

class Ecra3 extends ConsumerWidget {
  const Ecra3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);

    Map<int, double> totais = {};

    for (int i = 0; i < conta.participantes.length; i++) {
      totais[i] = 0;
    }

    for (int i = 0; i < conta.artigos.length; i++) {
      final artigo = conta.artigos[i];
      final selecionados = conta.atribuicoes[i] ?? [];

      if (selecionados.isEmpty) continue;

      double total = artigo.preco * artigo.quantidade;
      double porPessoa = total / selecionados.length;

      for (var p in selecionados) {
        totais[p] = totais[p]! + porPessoa;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conta Final"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Resumo por Participante",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...conta.participantes.asMap().entries.map((entry) {
            final index = entry.key;
            final participante = entry.value;

            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(participante.nome),
                trailing: Text(
                  "${totais[index]!.toStringAsFixed(2)} €",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}