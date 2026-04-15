import 'package:flutter/material.dart';
import '../models/participante.dart';
import '../models/artigo.dart';

class Ecra1 extends StatefulWidget {
  const Ecra1({super.key});

  @override
  State<Ecra1> createState() => _Ecra1State();
}

class _Ecra1State extends State<Ecra1> {
  // Listas
  List<Participante> participantes = [];
  List<Artigo> artigos = [];

  // Controllers
  final nomeController = TextEditingController();
  final artigoNomeController = TextEditingController();
  final precoController = TextEditingController();

  // Quantidade atual
  int quantidadeAtual = 1;

  @override
  Widget build(BuildContext context) {
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

            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome do participante",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
                  setState(() {
                    participantes.add(
                      Participante(nome: nomeController.text),
                    );
                    nomeController.clear();
                  });
                }
              },
              child: const Text("Adicionar Participante"),
            ),

            ...participantes.map(
              (p) => ListTile(
                title: Text(p.nome),
              ),
            ),

            const Divider(),

            // ===== ARTIGOS =====
            const Text(
              "Artigos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextField(
              controller: artigoNomeController,
              decoration: const InputDecoration(
                labelText: "Nome do artigo",
              ),
            ),

            TextField(
              controller: precoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Preço",
              ),
            ),

            const SizedBox(height: 10),

            // ===== QUANTIDADE (➕➖) =====
            Row(
              children: [
                const Text("Quantidade: "),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (quantidadeAtual > 1) quantidadeAtual--;
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
                Text("$quantidadeAtual"),
                IconButton(
                  onPressed: () {
                    setState(() {
                      quantidadeAtual++;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                if (artigoNomeController.text.isNotEmpty &&
                    precoController.text.isNotEmpty) {
                  setState(() {
                    artigos.add(
                      Artigo(
                        nome: artigoNomeController.text,
                        preco: double.parse(precoController.text),
                        quantidade: quantidadeAtual,
                      ),
                    );

                    artigoNomeController.clear();
                    precoController.clear();
                    quantidadeAtual = 1;
                  });
                }
              },
              child: const Text("Adicionar Artigo"),
            ),

            ...artigos.map(
              (a) => ListTile(
                title: Text(a.nome),
                subtitle: Text(
                  "${a.preco.toStringAsFixed(2)} € | Quantidade: ${a.quantidade}",
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (participantes.length < 2 || artigos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Precisas de pelo menos 2 participantes e 1 artigo",
                      ),
                    ),
                  );
                  return;
                }

                // Navegação futura
              },
              child: const Text("Próximo"),
            ),
          ],
        ),
      ),
    );
  }
}