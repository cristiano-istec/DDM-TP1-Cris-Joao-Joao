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
  // Controllers para recolher input do utilizador
  final nomeController = TextEditingController();
  final artigoController = TextEditingController();
  final precoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Obter estado global da aplicação (Riverpod)
    final conta = ref.watch(contaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),

      appBar: AppBar(
        title: const Text("Divisão de Conta"),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
      ),

      // Scroll principal da página
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Participantes
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Título
                const Text("Participantes",
                    style: TextStyle(color: Colors.white)),

                NeonInput(
                  controller: nomeController,
                  label: "Nome",
                ),

                NeonButton(
                  text: "Adicionar",
                  onPressed: () {
                    if (nomeController.text.isEmpty) return;

                    // Adiciona participante ao estado global
                    ref.read(contaProvider.notifier)
                        .adicionarParticipante(nomeController.text);

                    nomeController.clear();
                  },
                ),

                // Lista de participantes atuais
                ...conta.participantes.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person,
                        color: Colors.white),
                    title: Text(p.nome,
                        style: const TextStyle(color: Colors.white)),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () {
                        ref.read(contaProvider.notifier)
                            .removerParticipante(i);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Artigos
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Artigos",
                    style: TextStyle(color: Colors.white)),

                NeonInput(
                  controller: artigoController,
                  label: "Artigo",
                ),

                // Input preço artigo
                NeonInput(
                  controller: precoController,
                  label: "Preço",
                  keyboardType: TextInputType.number,
                ),

                // Contador de quantidade
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    NeonCircleButton(
                      icon: Icons.remove,
                      color: const Color(0xFF8B00FF),
                      onPressed: () {
                        ref.read(contaProvider.notifier)
                            .decrementarQuantidade();
                      },
                    ),

                    const SizedBox(width: 10),

                    // valor atual
                    Text("${conta.quantidadeAtual}",
                        style: const TextStyle(color: Colors.white)),

                    const SizedBox(width: 10),

                    NeonCircleButton(
                      icon: Icons.add,
                      color: const Color(0xFF00FFC6),
                      onPressed: () {
                        ref.read(contaProvider.notifier)
                            .incrementarQuantidade();
                      },
                    ),
                  ],
                ),

                NeonButton(
                  text: "Adicionar artigo",
                  onPressed: () {
                    if (artigoController.text.isEmpty ||
                        precoController.text.isEmpty) return;

                    // adiciona artigo ao estado global
                    ref.read(contaProvider.notifier).adicionarArtigo(
                          artigoController.text,
                          double.parse(precoController.text),
                        );

                    artigoController.clear();
                    precoController.clear();
                  },
                ),

                // lista de artigos atuais
                ...conta.artigos.asMap().entries.map((e) {
                  final i = e.key;
                  final a = e.value;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${a.nome} - ${a.preco}€ x${a.quantidade}",
                      style: const TextStyle(color: Colors.white),
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () {
                        ref.read(contaProvider.notifier)
                            .removerArtigo(i);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

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