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
      backgroundColor: const Color(0xFFF0FAF7),
      appBar: AppBar(
        title: const Text("Dividir Conta"),
        backgroundColor: const Color(0xFF00C49A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          ...conta.artigos.asMap().entries.map((entry) {
            final i = entry.key;
            final artigo = entry.value;
            final selecionados = conta.atribuicoes[i] ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artigo.nome,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  Text("${artigo.preco}€ x${artigo.quantidade}"),

                  TextButton(
                    onPressed: () {
                      ref.read(contaProvider.notifier)
                          .dividirPorTodos(i);
                    },
                    child: const Text("Dividir por todos"),
                  ),

                  ...conta.participantes.asMap().entries.map((p) {
                    return CheckboxListTile(
                      title: Text(p.value.nome),
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

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
              padding: const EdgeInsets.all(14),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Ecra3()),
              );
            },
            child: const Text("Calcular Conta"),
          )
        ],
      ),
    );
  }
}