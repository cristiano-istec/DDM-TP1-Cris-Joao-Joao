import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';
import 'ecra2.dart';

import '../widgets/neon_card.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_circle_button.dart';
import '../widgets/neon_input.dart';

class Ecra1 extends ConsumerStatefulWidget {
  const Ecra1({super.key});

  @override
  ConsumerState<Ecra1> createState() => _Ecra1State();
}

class _Ecra1State extends ConsumerState<Ecra1> {
  final nomeController = TextEditingController();
  final artigoController = TextEditingController();
  final precoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final conta = ref.watch(contaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text("Divisão de Conta"),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Participantes
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // FIX AQUI
              children: [

                const Text(
                  "Participantes",
                  style: TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 10),

                NeonInput(
                  controller: nomeController,
                  label: "Nome",
                ),

                const SizedBox(height: 10),

                NeonButton(
                  text: "Adicionar",
                  onPressed: () {
                    if (nomeController.text.isEmpty) return;

                    ref.read(contaProvider.notifier)
                        .adicionarParticipante(nomeController.text);

                    nomeController.clear();
                  },
                ),

                const SizedBox(height: 10),

                ...conta.participantes.map((p) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person,
                          color: Colors.white),
                      title: Text(
                        p.nome,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Artigos
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // FIX AQUI
              children: [

                const Text(
                  "Artigos",
                  style: TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 10),

                NeonInput(
                  controller: artigoController,
                  label: "Artigo",
                ),

                const SizedBox(height: 10),

                NeonInput(
                  controller: precoController,
                  label: "Preço",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    NeonCircleButton(
                      icon: Icons.remove,
                      color: const Color(0xFF8B00FF),
                      onPressed: () => ref
                          .read(contaProvider.notifier)
                          .decrementarQuantidade(),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      "${conta.quantidadeAtual}",
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(width: 10),

                    NeonCircleButton(
                      icon: Icons.add,
                      color: const Color(0xFF00FFC6),
                      onPressed: () => ref
                          .read(contaProvider.notifier)
                          .incrementarQuantidade(),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                NeonButton(
                  text: "Adicionar artigo",
                  onPressed: () {
                    if (artigoController.text.isEmpty ||
                        precoController.text.isEmpty) return;

                    ref.read(contaProvider.notifier).adicionarArtigo(
                          artigoController.text,
                          double.parse(precoController.text),
                        );

                    artigoController.clear();
                    precoController.clear();
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  "Lista de artigos",
                  style: TextStyle(color: Colors.grey),
                ),

                ...conta.artigos.map((a) => Text(
                      "${a.nome} - ${a.preco}€ x${a.quantidade}",
                      style: const TextStyle(color: Colors.white),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Avançar
          NeonButton(
            text: "AVANÇAR",
            onPressed: () {
              if (conta.participantes.length < 2 ||
                  conta.artigos.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Ecra2()),
              );
            },
          ),
        ],
      ),
    );
  }
}