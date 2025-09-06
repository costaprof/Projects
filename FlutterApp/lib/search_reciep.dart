import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:was_essen/global_decoration.dart';
import 'package:was_essen/models/suchbegriff.dart';
import 'package:intl/intl.dart';
import 'widgets/rezept_list.dart';

import 'DatenDb/datendb.dart';
import 'models/rezept.dart';
import 'widgets/filter_recipe.dart';

var isSearchClicked = ValueNotifier(true);

class SearchReciepe extends StatefulWidget {
  final List<Rezept> reciepeList;

  const SearchReciepe({super.key, required this.reciepeList});

  @override
  State<SearchReciepe> createState() => _SearchReciepeState();
}

class _SearchReciepeState extends State<SearchReciepe> {
  List<Rezept> _foundRezepte = [];
  List<Rezept> rezepte = [];
  String suchbegriff = "";
  TextEditingController searchRezeptController = TextEditingController();

  // this is responsable to update the list dynamically depending on the length of it
  var currentListLength = ValueNotifier(0);

  //Current Reciep List that need to be filtered
  List<Rezept> currentListReciep = [];

  List<Suchbegriff> stichwortSuchverlauf = [];

  @override
  void initState() {
    //initialize the reciep list with the list from home page
    resetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var datendb = context.watch<DatenDb>();
    stichwortSuchverlauf =
        sortStichwortSuchverlauf(datendb.stichwortsuchverlauf);
    // stichwortSuchverlauf = datendb.stichwortsuchverlauf;
    return Scaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10, bottom: 5, top: 5),
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.16,
                  width: MediaQuery.of(context).size.width * 0.77,
                  decoration: getBoxDeco(12, Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SizedBox(
                      //width: MediaQuery.of(context).size.width / 1.1 - 55,
                      child: TextField(
                        controller: searchRezeptController,
                        // autofocus: false,
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          labelText: "Suche nach Rezept",
                          suffixIcon: getSearchIconButton(datendb: datendb),
                        ),
                        onEditingComplete: () {
                          onEditingComplete(datendb);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  //When I click on button open a Bottom Menu
                  openFilterMenu();
                },
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.16,
                  width: MediaQuery.of(context).size.width * 0.16,
                  decoration: getBoxDeco(12, Colors.grey),
                  child: const Center(
                    child: Icon(
                      Icons.tune_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ValueListenableBuilder(
              valueListenable: isSearchClicked,
              builder: (context, value, _) {
                if (isSearchClicked.value) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: stichwortSuchverlauf.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            //leading: stichwortSuchverlauf.elementAt(index).image,
                            title: Text(
                              stichwortSuchverlauf.elementAt(index).suchbegriff,
                            ),
                            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(stichwortSuchverlauf
                                    .elementAt(index)
                                    .datetime)),
                            onTap: () {
                              //_onItemClicked(context, _foundRezepte.elementAt(index));
                              searchRezeptController.text = stichwortSuchverlauf.elementAt(index).suchbegriff;
                              onEditingComplete(datendb);
                              // String lSuchbegriff = stichwortSuchverlauf
                              //     .elementAt(index)
                              //     .suchbegriff;
                              // searchRezeptController.text = suchbegriff;
                              // datendb.addSuchbegriff(suchbegriff: suchbegriff);
                              // setState(() {});
                            },
                          );
                        }),
                  );
                } else {
                  // return Expanded(child: recieListWidget());
                  return rezeptListView(
                      rezepte: _foundRezepte, datendb: datendb, table: 0);
                }
              }),
          //Here List of Recipe after Filtring them
        ],
      ),
    );
  }

  IconButton getSearchIconButton({required DatenDb datendb}) {
    if (isSearchClicked.value) {
      return IconButton(
          onPressed: () {
            onEditingComplete(datendb);
          },
          icon: const Icon(Icons.search));
    } else {
      return IconButton(
          onPressed: () {
            searchRezeptController.clear();
            setState(() {
              isSearchClicked.value = true;
            });
          },
          icon: const Icon(Icons.close));
    }
  }

  void onEditingComplete(DatenDb datendb) {
    suchbegriff = searchRezeptController.text;
    if (suchbegriff != "") {
      datendb.addSuchbegriff(suchbegriff: suchbegriff);
    }
    _runFilter(suchbegriff, datendb);
    setState(() {
      isSearchClicked.value = false;
    });
  }

  void _runFilter(String enteredKeyword, DatenDb datendb) {
    List<Rezept> results = [];
    List<Rezept> dbRezept = datendb.rezepte;
    if (!listEquals(rezepte, dbRezept)) {
      rezepte = dbRezept;
    }

    if (enteredKeyword.isEmpty) {
      results = rezepte;
    } else {
      results = rezepte
          .where((rezept) =>
              rezept.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundRezepte = results;
    });
  }

  Widget imageReciepe(Rezept r) {
    return Image(
      image: r.image.image,
      height: 200,
      width: 200,
    );
  }

  void resetData() {
    setState(() {
      // searchRezeptController.teSearchHistoryByDatext = "";
      // currentListReciep = [];
      // currentListLength.value = currentListReciep.length;
      isSearchClicked.value = true;
    });
  }

  //--open filter function
  void openFilterMenu() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return FilterWidget(reciepeList: _foundRezepte);
        });
  }

  //function that filters searchHistory by date
  List<Suchbegriff> sortStichwortSuchverlauf(
      List<Suchbegriff> pStichwortSuchverlauf) {
    List<Suchbegriff> start = List.from(pStichwortSuchverlauf);
    List<Suchbegriff> result = [];
    for (int i = 0; i < pStichwortSuchverlauf.length; i++) {
      Suchbegriff? biggestDate;
      int pos = 0;
      for (int j = 0; j < start.length; j++) {
        if (biggestDate == null || j == 0) {
          biggestDate = start.elementAt(j);
          pos = j;
        } else if (biggestDate.datetime
                .compareTo(start.elementAt(j).datetime) <=
            0) {
          biggestDate = start.elementAt(j);
          pos = j;
        }
      }
      result.add(biggestDate!);
      start.removeAt(pos);
    }
    return result;
  }
}
