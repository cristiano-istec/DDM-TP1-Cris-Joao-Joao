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

      double total = artigo.preco * artigo.quantidade;
      double porPessoa = total / selecionados.length;

      for (var p in selecionados) {
        totais[p] = totais[p]! + porPessoa;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Conta Final"),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          ...conta.participantes.asMap().entries.map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFC6).withOpacity(0.3),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.value.nome,
                      style: const TextStyle(color: Colors.white)),

                  Text(
                    "${totais[p.key]!.toStringAsFixed(2)}€",
                    style: const TextStyle(
                      color: Color(0xFF00FFC6),
                      fontWeight: FontWeight.bold,
                    ),
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