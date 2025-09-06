import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:was_essen/DatenDb/datendb.dart';
import 'package:was_essen/pages/einkaufsliste/markt_suche.dart';
import 'package:was_essen/widgets/empty_page_placeholder.dart';
import 'package:was_essen/widgets/zutaten_hinzufuegen_bottom_sheet.dart';
import '../../models/list_zutat.dart';
import 'package:styled_widget/styled_widget.dart';

// class Einkaufsliste extends StatelessWidget {
//   const Einkaufsliste({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const EinkaufslisteContent();
//   }
// }

class Einkaufsliste extends StatefulWidget {
  const Einkaufsliste({super.key});

  @override
  State<Einkaufsliste> createState() => _EinkaufslisteState();
}

class _EinkaufslisteState extends State<Einkaufsliste> {
  final GlobalKey<AnimatedListState> _pendingListKey =
      GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _completedListKey =
      GlobalKey<AnimatedListState>();
  List<ListZutat> einkaufsliste = [];
  List<ListZutat> pendingItems = [];
  List<ListZutat> completedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final datenDb = Provider.of<DatenDb>(context, listen: false);
      // datenDb.fetchEinkaufsliste().then((_) {
      //   setState(() {
      //     // No additional state update needed, as fetchEinkaufsliste() updates the provider state
      //   });
      // });
    });
  }

  void _handleCheckboxChange(
      {required List<ListZutat> listZutaten,
      required int index,
      required bool? value,
      required DatenDb datendb}) async {
    if (value != null) {
      //final datenDb = Provider.of<DatenDb>(context, listen: false);
      final previousIndex = einkaufsliste.indexOf(listZutaten[index]);
      setState(() {
        listZutaten[index].erledigt = value;
      });
      if (value) {
        // Move item to completed
        if (_pendingListKey.currentState != null &&
            _completedListKey.currentState != null) {
          _pendingListKey.currentState?.removeItem(
            index,
            (context, animation) =>
                _buildRemovedItem(listZutaten[index], animation),
          );
          _completedListKey.currentState?.insertItem(0);
        }
      } else {
        // Move item to pending
        if (_completedListKey.currentState != null) {
          _completedListKey.currentState?.removeItem(
            index,
            (context, animation) =>
                _buildRemovedItem(listZutaten[index], animation),
          );
          _pendingListKey.currentState?.insertItem(0);
        }
      }
      datendb.updateEinkaufZutat(
          zutatID: listZutaten[index].id, erledigt: value ? 1 : 0);
    }
  }

  void _handleDeleteItem(
      {required ListZutat listZutat, required DatenDb datendb}) async {
    //final datenDb = Provider.of<DatenDb>(context, listen: false);
    final index = einkaufsliste.indexOf(listZutat);
    setState(() {
      // datenDb.einkaufsliste.remove(item);
    });
    await datendb.deleteEinkaufZutat(zutatID: listZutat.id);

    // Remove item from the list with animation
    if (listZutat.erledigt) {
      _completedListKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(listZutat, animation),
      );
    } else {
      _pendingListKey.currentState?.removeItem(
        index,
        (context, animation) => _buildRemovedItem(listZutat, animation),
      );
    }
  }

  void _handleNameChange(
      {required ListZutat listZutat,
      required String newName,
      required DatenDb datendb}) async {
    // final datenDb = Provider.of<DatenDb>(context, listen: false);
    setState(() {
      listZutat.name = newName;
    });
    await datendb.updateEinkaufZutat(
        zutatID: listZutat.id,
        anzahl: listZutat.anzahl.toInt(),
        erledigt: listZutat.erledigt ? 1 : 0);
  }

  void _handleAddItem({required DatenDb datendb}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ZutatHinzufuegenBottomSheet(
              onAddItem: (String name, double menge, String einheit) {
            _addItem(
                listZutat: ListZutat(
                    id: 0,
                    name: name,
                    erledigt: false,
                    anzahl: menge,
                    einheit: einheit),
                datendb: datendb);
          }),
        );
      },
    );
  }

  void _addItem({required ListZutat listZutat, required DatenDb datendb}) {
    //final datenDb = Provider.of<DatenDb>(context, listen: false);
    setState(() {
      datendb.addEinkaufZutat(
          name: listZutat.name,
          einheit: listZutat.einheit,
          anzahl: listZutat.anzahl,
          erledigt: listZutat.erledigt == true ? 1 : 0);
      //datenDb.einkaufsliste.add(newItem);

      _pendingListKey.currentState
          ?.insertItem(datendb.einkaufsliste.length - 1);
    });
  }

  void marktSucheAufmachen(
      BuildContext context, List<ListZutat> listZutaten) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MarktSucheScreen(items: listZutaten)),
    );
  }

  Widget _buildRemovedItem(ListZutat item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datenDb = Provider.of<DatenDb>(context);
    setState(() {
      einkaufsliste = datenDb.einkaufsliste;
    });
    pendingItems = einkaufsliste.where((item) => !item.erledigt).toList();
    completedItems = einkaufsliste.where((item) => item.erledigt).toList();

    return Scaffold(
      body: pendingItems.isEmpty && completedItems.isEmpty
          ? const EmptyPagePlaceholder(
              title: 'Your shopping list is empty!',
              message: 'Add ingredients here, or load them from a recipe')
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Einkaufen",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  getItemList(
                      listZutaten: pendingItems,
                      listKey: _pendingListKey,
                      datendb: datenDb),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Erledigt",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  getItemList(
                      listZutaten: completedItems,
                      listKey: _completedListKey,
                      datendb: datenDb),
                ],
              ),
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Zutaten hinzufügen',
            onTap: () => _handleAddItem(datendb: datenDb),
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.storefront),
            label: 'Marktsuche',
            onTap: () => marktSucheAufmachen(context, pendingItems),
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }

  AnimatedList getItemList(
      {required List<ListZutat> listZutaten,
      required GlobalKey<AnimatedListState> listKey,
      required DatenDb datendb}) {
    return AnimatedList(
      key: listKey,
      initialItemCount: listZutaten.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        return SizeTransition(
          sizeFactor: animation,
          child: getItemTile(
              listZutaten: listZutaten,
              index: index,
              listKey: listKey,
              datendb: datendb),
        );
      },
    );
  }

  Widget getItemTile(
      {required List<ListZutat> listZutaten,
      required int index,
      required GlobalKey<AnimatedListState> listKey,
      required DatenDb datendb}) {
    try {
      return Row(
        children: [
          Checkbox(
            value: listZutaten[index].erledigt,
            onChanged: (bool? value) {
              if (value != null) {
                //final datenDb = Provider.of<DatenDb>(context, listen: false);
                final previousIndex = einkaufsliste.indexOf(listZutaten[index]);
                setState(() {
                  listZutaten[index].erledigt = value;
                });
                if (value) {
                  // Move item to completed
                  if (_pendingListKey.currentState != null &&
                      _completedListKey.currentState != null) {
                    _pendingListKey.currentState?.removeItem(
                      index,
                      (context, animation) =>
                          _buildRemovedItem(listZutaten[index], animation),
                    );
                    _completedListKey.currentState?.insertItem(0);
                  }
                } else {
                  // Move item to pending
                  if (_completedListKey.currentState != null) {
                    _completedListKey.currentState?.removeItem(
                      index,
                      (context, animation) =>
                          _buildRemovedItem(listZutaten[index], animation),
                    );
                    _pendingListKey.currentState?.insertItem(0);
                  }
                }
                datendb.updateEinkaufZutat(
                    zutatID: listZutaten[index].id, erledigt: value ? 1 : 0);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: listZutaten[index].name),
              onSubmitted: (newValue) {
                _handleNameChange(
                    listZutat: listZutaten[index],
                    newName: newValue,
                    datendb: datendb);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          Column(
            children: [
              if (listZutaten[index].anzahl != 0 && listZutaten.length > index)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(listZutaten[index].anzahl.toString())
                        .padding(horizontal: 2.0),
                    Text(listZutaten[index].einheit).padding(horizontal: 2.0),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        listKey.currentState?.removeItem(
                          listZutaten.indexOf(listZutaten[index]),
                          (context, animation) => _buildItem(
                              listZutaten: listZutaten,
                              index: index,
                              animation: animation,
                              listKey: listKey,
                              datendb: datendb),
                        );
                        _handleDeleteItem(
                            listZutat: listZutaten[index], datendb: datendb);
                      },
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    listKey.currentState?.removeItem(
                      listZutaten.indexOf(listZutaten[index]),
                      (context, animation) => _buildItem(
                          listZutaten: listZutaten,
                          index: index,
                          animation: animation,
                          listKey: listKey,
                          datendb: datendb),
                    );
                    _handleDeleteItem(
                        listZutat: listZutaten[index], datendb: datendb);
                  },
                ),
            ],
          ),
        ],
      );
    } catch (error) {
      return Container();
    }
  }

  Widget _buildItem(
      {required List<ListZutat> listZutaten,
      required int index,
      required Animation<double> animation,
      required GlobalKey<AnimatedListState> listKey,
      required DatenDb datendb}) {
    return SizeTransition(
      sizeFactor: animation,
      child: getItemTile(
          listZutaten: listZutaten,
          index: index,
          listKey: listKey,
          datendb: datendb),
    );
  }
}
