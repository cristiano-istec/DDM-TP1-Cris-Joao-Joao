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
      backgroundColor: const Color(0xFFF0FAF7),
      appBar: AppBar(
        title: const Text("Conta Final"),
        backgroundColor: const Color(0xFF00C49A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Resumo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...conta.participantes.asMap().entries.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.value.nome),
                  Text(
                    "${totais[p.key]!.toStringAsFixed(2)}€",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}