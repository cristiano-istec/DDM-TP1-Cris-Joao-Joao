import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/providers.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import '../widgets/neon_circle_button.dart';
import '../widgets/neon_input.dart';
import 'ecra2.dart';

class Ecra1 extends ConsumerStatefulWidget {
  final int contaIndex;

  const Ecra1({super.key, required this.contaIndex});

  @override
  ConsumerState<Ecra1> createState() => _Ecra1State();
}

class _Ecra1State extends ConsumerState<Ecra1> {
  final nomeController = TextEditingController();
  final artigoController = TextEditingController();
  final precoController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> adicionarImagem(ImageSource origem) async {
    final XFile? imagem = await _picker.pickImage(
      source: origem,
      imageQuality: 85,
    );

    if (imagem == null) return;

    ref.read(contasProvider.notifier).guardarRecibo(
          widget.contaIndex,
          imagem,
        );
  }

  @override
  Widget build(BuildContext context) {
    final contas = ref.watch(contasProvider);

    if (widget.contaIndex >= contas.length) {
      return const Scaffold(
        body: Center(child: Text("Conta não encontrada")),
      );
    }

    final conta = contas[widget.contaIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(conta.nome),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Participantes", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 12),

                NeonInput(controller: nomeController, label: "Nome"),
                const SizedBox(height: 12),

                NeonButton(
                  text: "Adicionar participante",
                  onPressed: () {
                    final nome = nomeController.text.trim();

                    if (nome.isEmpty) {
                      Fluttertoast.showToast(msg: "Por favor, insira um nome.");
                      return;
                    }

                    if (conta.participantes.any((p) => p.nome == nome)) {
                      Fluttertoast.showToast(msg: "Este nome já foi adicionado.");
                      return;
                    }

                    ref.read(contasProvider.notifier).adicionarParticipante(
                          widget.contaIndex,
                          nome,
                        );

                    nomeController.clear();
                  },
                ),

                const SizedBox(height: 12),

                ...conta.participantes.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(p.nome, style: const TextStyle(color: Colors.white)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(contasProvider.notifier).removerParticipante(
                              widget.contaIndex,
                              i,
                            );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Artigos", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 12),

                NeonInput(controller: artigoController, label: "Artigo"),
                const SizedBox(height: 12),

                NeonInput(
                  controller: precoController,
                  label: "Preço",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NeonCircleButton(
                      icon: Icons.remove,
                      color: const Color(0xFF8B00FF),
                      onPressed: () {
                        ref.read(contasProvider.notifier).decrementarQuantidade(
                              widget.contaIndex,
                            );
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "${conta.quantidadeAtual}",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 16),
                    NeonCircleButton(
                      icon: Icons.add,
                      color: const Color(0xFF00FFC6),
                      onPressed: () {
                        ref.read(contasProvider.notifier).incrementarQuantidade(
                              widget.contaIndex,
                            );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                NeonButton(
                  text: "Adicionar artigo",
                  onPressed: () {
                    final nome = artigoController.text.trim();
                    final preco = double.tryParse(
                      precoController.text.replaceAll(',', '.'),
                    );

                    if (nome.isEmpty || precoController.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Por favor, preencha todos os campos.");
                      return;
                    }

                    if (preco == null || preco <= 0) {
                      Fluttertoast.showToast(msg: "Digite um preço válido.");
                      return;
                    }

                    ref.read(contasProvider.notifier).adicionarArtigo(
                          widget.contaIndex,
                          nome,
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

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "${a.nome} - ${a.preco.toStringAsFixed(2)}€ x${a.quantidade}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(contasProvider.notifier).removerArtigo(
                              widget.contaIndex,
                              i,
                            );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recibo", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => adicionarImagem(ImageSource.gallery),
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => adicionarImagem(ImageSource.camera),
                      icon: const Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),

                if (conta.reciboPath != null) ...[
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
                        File(conta.reciboPath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(contasProvider.notifier).removerRecibo(
                              widget.contaIndex,
                            );
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        "Remover recibo",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          NeonButton(
            text: "AVANÇAR",
            onPressed: () {
              if (conta.participantes.length < 2 || conta.artigos.isEmpty) {
                Fluttertoast.showToast(
                  msg: "Adicione pelo menos 2 participantes e 1 artigo.",
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Ecra2(contaIndex: widget.contaIndex),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}