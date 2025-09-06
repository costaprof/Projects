import 'package:flutter/material.dart';
import 'package:was_essen/models/list_zutat.dart';

class MarktSucheScreen extends StatefulWidget {
  final List<ListZutat> items;

  const MarktSucheScreen({super.key, required this.items});

  @override
  MarktSucheScreenState createState() => MarktSucheScreenState();
}

class MarktSucheScreenState extends State<MarktSucheScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marktsuche'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'In der Nähe'),
            Tab(text: 'Günstigster Preis'),
          ],
          indicatorColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Rewe Heinrichstr."),
                subtitle: Text('Distance: 2 km'),
                leading: const Icon(Icons.store),
                trailing: Text(widget.items[index].name),
                onTap: () {},
              );
            },
          ),
          ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(widget.items[index].name),
                subtitle: const Text('Cost: 1\$'),
                leading: const Icon(Icons.attach_money),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
