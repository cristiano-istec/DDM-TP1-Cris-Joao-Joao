import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';

class Ecra3 extends ConsumerWidget {
  const Ecra3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);

    final participantes = conta.participantes;
    final artigos = conta.artigos;
    final atribuicoes = conta.atribuicoes;

    // Mapa de Totais
    Map<int, double> totais = {};

    // inicializar
    for (int i = 0; i < participantes.length; i++) {
      totais[i] = 0;
    }

    // Calcular
    for (int i = 0; i < artigos.length; i++) {
      final artigo = artigos[i];

      final selecionados = atribuicoes[i] ?? [];

      if (selecionados.isEmpty) continue;

      double totalArtigo = artigo.preco * artigo.quantidade;

      double valorPorPessoa = totalArtigo / selecionados.length;

      for (var pIndex in selecionados) {
        totais[pIndex] = totais[pIndex]! + valorPorPessoa;
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

          // Mostrar Resultado
          ...participantes.asMap().entries.map((entry) {
            final index = entry.key;
            final participante = entry.value;

            final total = totais[index] ?? 0;

            return Card(
              child: ListTile(
                title: Text(participante.nome),
                trailing: Text(
                  "${total.toStringAsFixed(2)} €",
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