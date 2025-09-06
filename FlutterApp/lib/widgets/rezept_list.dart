import 'package:flutter/material.dart';

import '../models/rezept.dart';
import '../models/date_rezept.dart';
import '../DatenDb/datendb.dart';
import '../widgets/rezept_karte.dart';

Expanded rezeptListView(
    {required List<Rezept> rezepte, required DatenDb datendb, required int table}) {
  return Expanded(
    child: ListView.builder(
      itemCount: rezepte.length,
      itemBuilder: (context, index) => Card(
        key: ValueKey(rezepte.elementAt(index).id),
        color: Colors.grey,
        elevation: 4,
        child: ListTile(
          title: Column(
            children: [
              Row(
                children: [
                  Image(
                    image: rezepte.elementAt(index).image.image,
                    width: MediaQuery.of(context).size.width * 0.46,
                  ),
                  const SizedBox(width: 3),
                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.32,
                        width: MediaQuery.of(context).size.width * 0.39,
                        child: Center(
                          child: Text(
                            softWrap: true,
                            rezepte.elementAt(index).name,
                            style: const TextStyle(
                                fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                      rezepte.elementAt(index).getBewertungSterne(
                          textColor: Colors.white,
                          text1: "",
                          text2: "",
                          iconColor: Colors.yellow,
                          iconSize: 20),
                      getRezeptDatetime(table: table, rezept: rezepte.elementAt(index)),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.39,
                        //height: 10,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              int rezeptID = rezepte.elementAt(index).id;
                              if(table==0){
                                datendb.deleteFromRezepte(id: rezeptID);
                                datendb.deleteRezeptZutaten(rezeptID: rezeptID);
                              }else if(table==1){
                                datendb.deleteFromKochverlauf(id: rezeptID);
                              }else if(table==2){
                                datendb.deleteFromMeineRezepte(rezeptID: rezeptID);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Recipe deleted successfully')),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            _onItemClicked(context, rezepte.elementAt(index));
          },
        ),
      ),
    ),
  );
}

void _onItemClicked(BuildContext context, Rezept rezept) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RezeptKarte(
        rezept: rezept,
      ),
    ),
  );
}

Widget getRezeptDatetime({required int table, required Rezept rezept}){
  if(table == 1){
    DateRezept dateRezept = rezept as DateRezept;
    return dateRezept.getDate();
  }else{
    return Container();
  }
}
