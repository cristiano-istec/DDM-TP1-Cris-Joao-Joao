import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';
import 'ecra2.dart';

class Ecra1 extends ConsumerStatefulWidget {
  const Ecra1({super.key});

  @override
  ConsumerState<Ecra1> createState() => _Ecra1State();
}

class _Ecra1State extends ConsumerState<Ecra1> {
  final nomeController = TextEditingController();
  final artigoNomeController = TextEditingController();
  final precoController = TextEditingController();

  // --- Botão redondo reutilizável ---
  Widget _circleBtn(IconData icon, VoidCallback onPressed, Color color) {
    return Ink(
      decoration: ShapeDecoration(
        color: color,
        shape: const CircleBorder(),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conta = ref.watch(contaProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF8), // fundo suave
      appBar: AppBar(
        title: const Text("Divisão de Conta"),
        backgroundColor: const Color(0xFF00C49A), // verde mint
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // ---------------- PARTICIPANTES ----------------
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Participantes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome do participante",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C49A),
                    ),
                    onPressed: () {
                      if (nomeController.text.isNotEmpty) {
                        ref.read(contaProvider.notifier)
                            .adicionarParticipante(nomeController.text);
                        nomeController.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Adicionar"),
                  ),

                  const SizedBox(height: 10),

                  ...conta.participantes.map((p) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(p.nome),
                        ),
                      )),
                ],
              ),
            ),
          ),

          const Divider(height: 30),

          // ---------------- ARTIGOS ----------------
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Artigos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: artigoNomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome do artigo",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fastfood),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: precoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Preço",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.euro),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleBtn(
                        Icons.remove,
                        () => ref.read(contaProvider.notifier)
                            .decrementarQuantidade(),
                        const Color(0xFF00C49A), // azul
                      ),

                      const SizedBox(width: 18),

                      Text(
                        "${conta.quantidadeAtual}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 18),

                      _circleBtn(
                        Icons.add,
                        () => ref.read(contaProvider.notifier)
                            .incrementarQuantidade(),
                        const Color(0xFF00C49A), // verde
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C49A),
                    ),
                    onPressed: () {
                      if (artigoNomeController.text.isNotEmpty &&
                          precoController.text.isNotEmpty) {
                        ref.read(contaProvider.notifier).adicionarArtigo(
                              artigoNomeController.text,
                              double.parse(precoController.text),
                            );

                        artigoNomeController.clear();
                        precoController.clear();
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Adicionar Artigo"),
                  ),

                  const SizedBox(height: 10),

                  ...conta.artigos.map((a) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.fastfood),
                          title: Text(a.nome),
                          subtitle: Text(
                            "${a.preco.toStringAsFixed(2)}€ x${a.quantidade}",
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------- AVANÇAR ----------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final participantes = conta.participantes;
                final artigos = conta.artigos;

                if (participantes.length < 2 || artigos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Precisas de pelo menos 2 participantes e 1 artigo"),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Ecra2()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                backgroundColor: const Color(0xFF0077B6),
              ),
              child: const Text(
                "AVANÇAR",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}