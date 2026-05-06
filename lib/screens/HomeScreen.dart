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
        slivers: <Widget>[

          SliverList.builder(
            key: centerKey,
            itemCount: contas.length,
            itemBuilder: (BuildContext context, int index) {

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00FFC6), width: 2),
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
                    title: Text('Conta $index'),
                    titleAlignment: ListTileTitleAlignment.center,

                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Ecra1(contaIndex: index),
                      ),
                    ),

                    onLongPress: () {
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(0, 0, 0, 0), // Adjust position as needed
                        items: [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Remover Conta'),
                          ),
                        ],
                      ).then((value) {
                        if (value == 'delete') {
                          ref.read(contasProvider.notifier).removerConta(index);
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