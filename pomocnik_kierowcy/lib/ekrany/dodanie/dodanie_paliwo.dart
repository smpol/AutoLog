import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomocnik_kierowcy/inne/reklama.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../ekran_glowny.dart';

class DodajPaliwo extends StatefulWidget {
  const DodajPaliwo({Key? key}) : super(key: key);

  @override
  State<DodajPaliwo> createState() => _DodajPaliwoState();
}

class _DodajPaliwoState extends State<DodajPaliwo> {
  final _dodajPaliwoKey = GlobalKey<FormState>();
  DateTime _dateTime = DateTime.now();

  final TextEditingController _nazwaStacji = TextEditingController();
  final TextEditingController _iloscPaliwa = TextEditingController();
  final TextEditingController _przebieg = TextEditingController();
  final TextEditingController _kosztTankowania = TextEditingController();
  final TextEditingController _notatkaTankowania = TextEditingController();

  String convertKropkeNaPrzecinek(String text) {
    return text.replaceAll(".", ",");
  }

  void dodajWpis() {
    var box = Hive.openBox("tankowanie");
    String nazwaStacji = "";
    String notatka = "";
    if (_nazwaStacji.text.isEmpty) {
      nazwaStacji = "Brak nazwy stacji";
    } else {
      nazwaStacji = _nazwaStacji.text;
    }
    if (_notatkaTankowania.text.isEmpty) {
      notatka = "";
    } else {
      notatka = _notatkaTankowania.text;
    }
    box.then((value) => value.add({
      "nazwa_stacji": nazwaStacji,
      "ilosc_paliwa": convertKropkeNaPrzecinek(_iloscPaliwa.text),
      "przebieg": _przebieg.text,
      "koszt_tankowania": convertKropkeNaPrzecinek(_kosztTankowania.text),
      "data_tankowania": _dateTime,
      "notatka_tankowania": notatka
    }));
    //print wynik
    debugPrint(box.toString());
    //back to main screen
  }

  List<String> sugestie = [
    "Orlen",
    "BP",
    "Circle K",
    "Shell",
    "Moya",
    "Lotos",
    "Amic",
    "Aviva",
    "MOL"
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _dodajPaliwoKey,
      child: Scaffold(
          appBar: AppBar(
              title: const Text("Dodanie tankowania"),
              //add menu
              actions: const [
                // IconButton(
                //   icon: const Icon(Icons.add_chart_sharp),
                //   onPressed: () {
                //     print("kliknięto przycisk");
                //   },
                // )
              ]),
          body: Material(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(children: [
                                    ListTile(
                                      title: const Text("Data tankowania"),
                                      // subtitle: Text(
                                      //     "Domyślnie ustawiona jest dzisiejsza data"),
                                      subtitle: Text(
                                          "Ustawiona data to: ${_dateTime.day}.${_dateTime.month}.${_dateTime.year}"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: FilledButton(
                                        onPressed: () async {
                                          DateTime? nowaWybranaData =
                                          await showDatePicker(
                                              context: context,
                                              initialDate: _dateTime,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime.now());
                                          if (nowaWybranaData == null) {
                                            return;
                                          } else {
                                            setState(() {
                                              _dateTime = nowaWybranaData;
                                            });
                                          }
                                        },
                                        child: const Text("Wybierz Datę"),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const ListTile(
                                        title: Text("Nazwa stacji"),
                                        subtitle: Text(
                                            "Wybierz lub wpisz nazwę stacji benzynowej na której tankowałeś"),
                                      ),
                                      Container(
                                          margin: const EdgeInsets.all(10.0),
                                          child:
                                          // TextFormField(
                                          //   controller: _nazwaStacji,
                                          //   // validator: (value) {
                                          //   //   if (value == null ||
                                          //   //       value.isEmpty) {
                                          //   //     return "Wpisz nazwe stacji";
                                          //   //   }
                                          //   //   return null;
                                          //   // },
                                          //   decoration: const InputDecoration(
                                          //     labelText: 'Nazwa stacji',
                                          //   ),
                                          // ),
                                          TypeAheadField(
                                            animationStart: 0,
                                            animationDuration: Duration.zero,
                                            textFieldConfiguration: TextFieldConfiguration(
                                                controller: _nazwaStacji,
                                                autofocus: false,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                                decoration: const InputDecoration(
                                                    labelText:
                                                    "Nazwa Stacji Benzynowej",
                                                    border:
                                                    OutlineInputBorder())),
                                            suggestionsCallback: (pattern) {
                                              List<String> matches = <String>[];
                                              matches.addAll(sugestie);

                                              matches.retainWhere((s) {
                                                return s.toLowerCase().contains(
                                                    pattern.toLowerCase());
                                              });
                                              return matches;
                                            },
                                            itemBuilder: (context, sone) {
                                              return Card(
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets.all(10),
                                                    child: Text(sone.toString()),
                                                  ));
                                            },
                                            onSuggestionSelected: (suggestion) {
                                              _nazwaStacji.text =
                                                  suggestion.toString();
                                            },
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const ListTile(
                                        title: Text("Ilość paliwa"),
                                        subtitle: Text(
                                            "Wpisz ilość paliwa jaką zatankowałeś"),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          controller: _iloscPaliwa,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Wpisz ilość paliwa";
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            //tylko cyfry od 0,01 do 1000 i tylko przecinek lub kropka
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+(\.|\,)?\d{0,2}')),
                                          ],
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                              labelText: 'Ilość paliwa',
                                              border:
                                              OutlineInputBorder()
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ListTile(
                                          title: const Text("Przebieg pojazdu"),
                                          subtitle: FutureBuilder(
                                            future: znajdzNajwiekszyPrzebieg(),
                                            builder: (context, snapshot) {
                                              if ((snapshot.data?.toInt() ?? 0) > 0) {
                                                return Text(
                                                    "Ostatni największy przebieg pojazdu zapisany to: ${snapshot.data} km");
                                              } else {
                                                return const Text(
                                                    "Wprowadź przebieg pojazdu który był podczas tankowania");
                                              }
                                            },
                                          )),
                                      Container(
                                          margin: const EdgeInsets.all(10.0),
                                          child: FutureBuilder(
                                              future:
                                              znajdzNajwiekszyPrzebieg(),
                                              builder: (content, snapshot) {
                                                return TextFormField(
                                                  controller: _przebieg,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return "Wpisz przebieg pojazdu";
                                                    }
                                                    // if (int.parse(value) <
                                                    //     snapshot.data!) {
                                                    //   return "Przebieg nie może być mniejszy niż ${snapshot.data} km";
                                                    // }
                                                    return null;
                                                  },
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(r'^\d+')),
                                                  ],
                                                  keyboardType:
                                                  const TextInputType
                                                      .numberWithOptions(
                                                      decimal: false),
                                                  decoration:
                                                  const InputDecoration(
                                                      labelText:
                                                      'KM',
                                                      border:
                                                      OutlineInputBorder()
                                                  ),
                                                );
                                              })),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const ListTile(
                                        title:
                                        Text("Całkowity koszt tankowania"),
                                        subtitle: Text(
                                            "Wpisz ile zapłaciłeś za zatankowanie pojazdu"),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          controller: _kosztTankowania,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Wpisz koszt tankowania";
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            // FilteringTextInputFormatter.allow(
                                            //     RegExp(r'^\d+\.?\d{0,2}')),
                                            //RexExp dozwala na wpisanie tylko cyfr i kropki
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+(\.|\,)?\d{0,2}')),
                                          ],
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                              labelText: 'Kwota',
                                              border:
                                              OutlineInputBorder()
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const ListTile(
                                        title:
                                        Text("Notatka tankowania"),
                                        subtitle: Text(
                                            "Opcjonalne"),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          maxLines: 4,
                                          controller: _notatkaTankowania,
                                          decoration: const InputDecoration(
                                            labelText: 'Wpisz tutaj swoją notatkę',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FilledButton(
                                onPressed: () {
                                  if (_dodajPaliwoKey.currentState!
                                      .validate()) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Poprawnie dodano wpis"),
                                    ));
                                    dodajWpis();
                                    Navigator.popUntil(
                                        context, ModalRoute.withName("/"));
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text("Dodaj Wpis Tankowania"),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const ReklamaBaner(),
              ],
            ),
          )),
    );
  }
}
