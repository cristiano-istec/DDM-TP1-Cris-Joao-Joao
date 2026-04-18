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

  BoxShadow neonGlow(Color color) {
    return BoxShadow(
      color: color.withOpacity(0.6),
      blurRadius: 20,
      spreadRadius: 2,
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onPressed, Color color) {
    return Container(
      decoration: ShapeDecoration(
        color: color,
        shape: const CircleBorder(),
        shadows: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

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

          _card([
            _title("Participantes"),

            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Nome"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: _btnStyle(),
              onPressed: () {
                if (nomeController.text.isEmpty) return;
                ref.read(contaProvider.notifier)
                    .adicionarParticipante(nomeController.text);
                nomeController.clear();
              },
              child: const Text("Adicionar"),
            ),

            ...conta.participantes.map((p) => ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: Text(p.nome,
                      style: const TextStyle(color: Colors.white)),
                )),
          ]),

          const SizedBox(height: 16),

          _card([
            _title("Artigos"),

            TextField(
              controller: artigoNomeController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Nome artigo"),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: precoController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Preço"),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleBtn(Icons.remove, () {
                  ref.read(contaProvider.notifier).decrementarQuantidade();
                }, const Color(0xFF8B00FF)),

                const SizedBox(width: 16),

                Text("${conta.quantidadeAtual}",
                    style: const TextStyle(color: Colors.white, fontSize: 18)),

                const SizedBox(width: 16),

                _circleBtn(Icons.add, () {
                  ref.read(contaProvider.notifier).incrementarQuantidade();
                }, const Color(0xFF00FFC6)),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: _btnStyle(),
              onPressed: () {
                if (artigoNomeController.text.isEmpty ||
                    precoController.text.isEmpty) return;

                ref.read(contaProvider.notifier).adicionarArtigo(
                      artigoNomeController.text,
                      double.parse(precoController.text),
                    );

                artigoNomeController.clear();
                precoController.clear();
              },
              child: const Text("Adicionar Artigo"),
            ),

            ...conta.artigos.map((a) => ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.white),
                  title: Text(a.nome,
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "${a.preco}€ x${a.quantidade}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )),
          ]),

          const SizedBox(height: 20),

          ElevatedButton(
            style: _btnStyle(),
            onPressed: () {
              if (conta.participantes.length < 2 ||
                  conta.artigos.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Ecra2()),
              );
            },
            child: const Text("AVANÇAR"),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFC6).withOpacity(0.4),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _title(String t) => Text(
        t,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      );

  InputDecoration _input(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00FFC6))),
      );

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
        shadowColor: const Color(0xFF00FFC6),
        elevation: 10,
      );
}