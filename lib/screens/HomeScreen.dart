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
      appBar: AppBar(
        title: const Text('Press on the plus to add items above and below'),
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
      body: CustomScrollView(
        center: centerKey,
        slivers: <Widget>[
          SliverList.builder(
            key: centerKey,
            itemCount: bottom.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text('Item ${bottom[index]}'),
                onTap: () =>  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Ecra1()),
               )  
             );
            },
          ),
        ],
      ),
    );
  }
}