import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/neon_card.dart';

class Ecra3 extends ConsumerWidget {
  final int contaIndex;

  const Ecra3({super.key, required this.contaIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contas = ref.watch(contasProvider);

    if (contaIndex >= contas.length) {
      return const Scaffold(
        body: Center(child: Text("Conta não encontrada")),
      );
    }

    final conta = contas[contaIndex];

    Map<int, double> totais = {};

    for (int i = 0; i < conta.participantes.length; i++) {
      totais[i] = 0;
    }

    for (int i = 0; i < conta.artigos.length; i++) {
      final artigo = conta.artigos[i];
      final atribuicoes = conta.atribuicoes[i] ?? {};

      for (int p = 0; p < conta.participantes.length; p++) {
        final qtdConsumida = atribuicoes[p] ?? 0;
        totais[p] = totais[p]! + (artigo.preco * qtdConsumida);
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
            return NeonCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p.value.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
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

          if (conta.reciboBase64 != null) ...[
            const SizedBox(height: 20),

            const Text(
              "Recibo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.black,
                child: Image.memory(
                  base64Decode(conta.reciboBase64!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}