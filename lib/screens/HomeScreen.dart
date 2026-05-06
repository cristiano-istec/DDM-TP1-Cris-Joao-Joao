import 'package:ddm_pdmi_tp01/screens/ecra1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<int> top = <int>[];
  List<int> bottom = <int>[0];

  @override
  Widget build(BuildContext context) {
    const Key centerKey = ValueKey<String>('bottom-sliver-list');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Clica em algum botão para iniciar uma conta'),
        backgroundColor: const Color(0xFF00FFC6),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              top.add(-top.length - 1);
              bottom.add(bottom.length);
            });
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
            itemCount: bottom.length,
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
                        color: const Color(0xFF00FFC6).withOpacity(0.5), // glow verde
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    textColor: Colors.white,
                    title: Text('Conta ${bottom[index]}'),
                    titleAlignment: ListTileTitleAlignment.center,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Ecra1()),
                    ),
                    onLongPress: () => setState(() {
                      bottom.removeAt(index);
                    }),
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