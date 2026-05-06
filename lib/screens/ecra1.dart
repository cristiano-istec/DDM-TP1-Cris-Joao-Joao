import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/providers.dart';
import 'ecra2.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();
  XFile? reciboImagem;

  Future<void> adicionarImagem(ImageSource origem) async {
  final XFile? imagem = await _picker.pickImage(
    source: origem,
    imageQuality: 85,
  );

  if (imagem != null) {
    setState(() {
      reciboImagem = imagem;
    });
  }
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
        children: <Widget>[

          // Participantes
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Participantes",
                    style: TextStyle(color: Colors.white)),

                const SizedBox(height: 12),

                NeonInput(
                  controller: nomeController,
                  label: "Nome",
                ),

                const SizedBox(height: 12),

                NeonButton(
                  text: "Adicionar participante",
                  onPressed: () {
                    if (nomeController.text.isEmpty) { //verifica se o campo está vazio
                      Fluttertoast.showToast(
                        msg: "Por favor, insira um nome.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    if (conta.participantes.any((pessoa) => pessoa.nome == nomeController.text)) { // Verifica se o nome já existe
                      Fluttertoast.showToast( 
                        msg: "Este nome já foi adicionado.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    ref.read(contaProvider.notifier)
                        .adicionarParticipante(nomeController.text);

                    nomeController.clear();
                  },
                ),

                const SizedBox(height: 12),

                ...conta.participantes.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person,
                          color: Colors.white),
                      title: Text(
                        p.nome,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () {
                          ref.read(contaProvider.notifier)
                              .removerParticipante(i);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Artigos
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text("Artigos",
                    style: TextStyle(color: Colors.white)),

                const SizedBox(height: 12),

                NeonInput(
                  controller: artigoController,
                  label: "Artigo",
                ),

                const SizedBox(height: 12),

                NeonInput(
                  controller: precoController,
                  label: "Preço",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // QUANTIDADE
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

                    const SizedBox(width: 16),

                    Text(
                      "${conta.quantidadeAtual}",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(width: 16),

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

                const SizedBox(height: 16),

                NeonButton(
                  text: "Adicionar artigo",
                  onPressed: () {
                    if (artigoController.text.isEmpty ||
                        precoController.text.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "Por favor, preencha todos os campos.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    final preco = double.tryParse(
                      precoController.text.replaceAll(',', '.'),
                    );
                    if (preco == null || preco <= 0) {
                      Fluttertoast.showToast(
                        msg: preco == null
                            ? "Digite um preço válido."
                            : "O preço deve ser um valor positivo.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    ref.read(contaProvider.notifier).adicionarArtigo(
                          artigoController.text,
                          preco,
                        );

                    artigoController.clear();
                    precoController.clear();
                  },
                ),

                const SizedBox(height: 12),

                ...conta.artigos.asMap().entries.map((e) {
                  final i = e.key;
                  final a = e.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
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
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),


// Recibo
NeonCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Recibo",
        style: TextStyle(color: Colors.white),
      ),

      const SizedBox(height: 12),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              adicionarImagem(ImageSource.gallery);
            },
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 20),

          IconButton(
            onPressed: () {
              adicionarImagem(ImageSource.camera);
            },
            icon: const Icon(
              Icons.add_a_photo_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      if (reciboImagem != null) ...[
        const SizedBox(height: 10),

        const Text(
          "Imagem associada com sucesso",
          style: TextStyle(color: Colors.greenAccent),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 220,
            width: double.infinity,
            color: Colors.black,
            child: Image.file(
              File(reciboImagem!.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    ],
  ),
),

          // Avançar
          NeonButton(
            text: "AVANÇAR",
            onPressed: () {
              if (conta.participantes.length < 2 ||
                  conta.artigos.isEmpty) {
                Fluttertoast.showToast(
                  msg: "Por favor, adicione pelo menos 2 participantes e 1 artigo.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
                return;
              }

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