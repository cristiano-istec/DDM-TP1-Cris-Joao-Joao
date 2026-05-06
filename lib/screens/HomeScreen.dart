import 'package:ddm_pdmi_tp01/screens/ecra1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _mostrarDialogEditarNome(int index, String nomeAtual) {
    final controller = TextEditingController(text: nomeAtual);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar nome da conta"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nome da conta",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final novoNome = controller.text.trim();

                if (novoNome.isEmpty) return;

                ref.read(contasProvider.notifier).editarNomeConta(
                      index,
                      novoNome,
                    );

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey<String>('bottom-sliver-list');

    final contas = ref.watch(contasProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Clica no + para iniciar uma conta'),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            ref.read(contasProvider.notifier).adicionarConta();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Clique para editar as contas, segure para deletar uma conta',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        },
        child: const Icon(Icons.info),
      ),
      body: CustomScrollView(
        center: centerKey,
        slivers: [
          SliverList.builder(
            key: centerKey,
            itemCount: contas.length,
            itemBuilder: (context, index) {
              final conta = contas[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF00FFC6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00FFC6).withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    textColor: Colors.white,
                    title: Text(conta.nome),
                    titleAlignment: ListTileTitleAlignment.center,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Ecra1(contaIndex: index),
                        ),
                      );
                    },
                    onLongPress: () {
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                        items: const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Remover Conta'),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar Nome'),
                          ),
                        ],
                      ).then((value) {
                        if (value == 'delete') {
                          ref.read(contasProvider.notifier).removerConta(index);
                        }

                        if (value == 'edit') {
                          _mostrarDialogEditarNome(index, conta.nome);
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}