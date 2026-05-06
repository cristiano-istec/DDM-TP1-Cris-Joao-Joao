import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/neon_card.dart';

class Ecra3 extends ConsumerWidget {
  const Ecra3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conta = ref.watch(contaProvider);

    // mapa com totais por participante
    Map<int, double> totais = {};

    // inicializar valores
    for (int i = 0; i < conta.participantes.length; i++) {
      totais[i] = 0;
    }

    // calcular divisão de custos com base em quantidades
    for (int i = 0; i < conta.artigos.length; i++) {
      final artigo = conta.artigos[i];
      final atribuicoes = conta.atribuicoes[i] ?? {};

      double precoUnitario = artigo.preco;

      // Para cada participante, adicionar o custo baseado na quantidade consumida
      for (int p = 0; p < conta.participantes.length; p++) {
        final qtdConsumida = atribuicoes[p] ?? 0;

        totais[p] =
            totais[p]! + (precoUnitario * qtdConsumida);
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

          // RESULTADO FINAL
          ...conta.participantes.asMap().entries.map((p) {

            return NeonCard(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  // nome participante
                  Text(
                    p.value.nome,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  // valor a pagar
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

          // RECIBO
          if (conta.reciboImagem != null) ...[

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
              borderRadius:
                  BorderRadius.circular(16),
              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.black,
                child: Image.file(
                  File(conta.reciboImagem!.path),
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