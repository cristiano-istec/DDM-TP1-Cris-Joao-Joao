import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/providers.dart';

class Ecra1 extends ConsumerWidget {
  Ecra1({super.key});

  final nomeController = TextEditingController();
  final artigoNomeController = TextEditingController();
  final precoController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(contaProvider);
    final notifier = ref.read(contaProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Divisão de Conta"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            // ===== PARTICIPANTES =====
            const Text(
              "Participantes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(controller: nomeController),

            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
                  notifier.adicionarParticipante(nomeController.text);
                  nomeController.clear();
                }

                if (state.participantes.length < 2 || state.artigos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Precisas de pelo menos 2 participantes e 1 artigo",
                      ),
                    ),
                  );
                } 
              },
              
              child: const Text("Adicionar Participante"),
            ),

            ...state.participantes.map(
              (p) => ListTile(title: Text(p.nome)),
            ),

            const Divider(),

            // ===== ARTIGOS =====
            const Text("Artigos"),

            TextField(controller: artigoNomeController),

            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
            ),

            // QUANTIDADE
            Row(
              children: [
                IconButton(
                  onPressed: notifier.decrementarQuantidade,
                  icon: const Icon(Icons.remove),
                ),
                Text("${state.quantidadeAtual}"),
                IconButton(
                  onPressed: notifier.incrementarQuantidade,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                if (artigoNomeController.text.isNotEmpty &&
                    precoController.text.isNotEmpty) {

                  notifier.adicionarArtigo(
                    artigoNomeController.text,
                    double.parse(precoController.text),
                  );

                  artigoNomeController.clear();
                  precoController.clear();
                }

                if (state.participantes.length < 2 || state.artigos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Precisas de pelo menos 2 participantes e 1 artigo",
                      ),
                    ),
                  );
                } 
              },
              child: const Text("Adicionar Artigo"),
            ),

            ...state.artigos.map(
              (a) => ListTile(
                title: Text(a.nome),
                subtitle: Text(
                  "${a.preco} € | Qtd: ${a.quantidade}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}