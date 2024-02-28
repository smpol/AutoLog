import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pomocnik_kierowcy/inne/reklama.dart';
// import 'package:hive/hive.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../ekran_glowny.dart';

class DodajSerwis extends StatefulWidget {
  const DodajSerwis({Key? key}) : super(key: key);

  @override
  State<DodajSerwis> createState() => _DodajSerwisState();
}

class _DodajSerwisState extends State<DodajSerwis> {
  bool przypomnienieKm = false;
  bool przypomnienieMiesiace = false;

  final _dodajSerwisKey = GlobalKey<FormState>();
  DateTime _dateTime = DateTime.now();
  DateTime _dataKolejnegoSerwisu =
  DateTime.now().add(const Duration(days: 365));

  final TextEditingController _tytulSerwisu = TextEditingController();
  final TextEditingController _opisSerwisu = TextEditingController();
  final TextEditingController _przebieg = TextEditingController();
  final TextEditingController _kosztSerwisu = TextEditingController();
  final TextEditingController _przebiegKolejnejSerwisu =
  TextEditingController();

  String convertKropkeNaPrzecinek(String text) {
    return text.replaceAll(".", ",");
  }

  void dodajWpis() {
    DateTime temp = DateTime(0);
    double temp2 = -1;

    if (przypomnienieKm == true) {
      temp2 = double.parse(_przebiegKolejnejSerwisu.text);
    } else {
      temp2 = -1;
    }

    if (przypomnienieMiesiace == true) {
      temp = _dataKolejnegoSerwisu;
    } else {
      temp = DateTime(0);
    }

    var box = Hive.openBox("naprawy");
    box.then((value) => value.add({
      "tytul_naprawy": _tytulSerwisu.text,
      "opis_naprawy": _opisSerwisu.text,
      "przebieg": _przebieg.text,
      "koszt_naprawy": convertKropkeNaPrzecinek(_kosztSerwisu.text),
      "data_naprawy": _dateTime,
      "przypomnienie_miesiace": temp,
      "przypomnienie_km": temp2,
    }));
  }

  List<String> sugestie = [
    "Wymiana oleju silnikowego",
    "Wymiana oleju skrzyni biegów",
    "Wymiana płynu chłodzącego",
    "Serwis klimatyzacji",
    "Wymiana płynu hamulcowego",
    "Przegląd ogólny",
    "Badaie techniczne",
    "Ubezpieczenie OC",
    "Wymiana filtru powietrza",
    "Wymiana filtra paliwa",
    "Wymiana filtra oleju",
    "Wymiana filtra kabinowego",
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _dodajSerwisKey,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Dodanie serwisu"),
          ),
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
                                child: Column(children: [
                                  ListTile(
                                    title: const Text("Data Serwisu"),
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
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Text("Wybierz Datę"),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              Card(
                                child: Column(
                                  children: [
                                    const ListTile(
                                      title: Text("Nazwa serwisu"),
                                      subtitle: Text(
                                          "Wybierz z listy serwis lub wpisz własną nazwę"),
                                    ),
                                    Container(
                                        margin: const EdgeInsets.all(10.0),
                                        child: TypeAheadField(
                                          animationStart: 0,
                                          animationDuration: Duration.zero,
                                          textFieldConfiguration:
                                          TextFieldConfiguration(
                                              controller: _tytulSerwisu,
                                              autofocus: false,
                                              style: const TextStyle(
                                                  fontSize: 15),
                                              decoration: const InputDecoration(
                                                  labelText: "Nazwa serwisu",
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
                                                  padding: const EdgeInsets.all(10),
                                                  child: Text(sone.toString()),
                                                ));
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            _tytulSerwisu.text =
                                                suggestion.toString();
                                          },
                                        )),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: [
                                    const ListTile(
                                      title: Text("Opis serwisu"),
                                      subtitle: Text("Opcjonalny"),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        maxLines: 4,
                                        controller: _opisSerwisu,
                                        decoration: const InputDecoration(
                                          labelText: 'Opis serwisu',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: [
                                    ListTile(
                                        title: const Text("Przebieg pojazdu"),
                                        subtitle: FutureBuilder(
                                          future: znajdzNajwiekszyPrzebieg(),
                                          builder: (context, snapshot) {
                                            if ((snapshot.data?.toInt() ?? 0)>0) {
                                              return Text(
                                                  "Ostatni największy przebieg pojazdu zapisany to: ${snapshot.data} km");
                                            } else {
                                              return const Text(
                                                  "Wprowadź przebieg pojazdu który był podczas serwisu");
                                            }
                                          },
                                        )),
                                    Container(
                                      margin: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: _przebieg,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Wpisz przebieg pojazdu";
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+')),
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: false),
                                        decoration: const InputDecoration(
                                            labelText: 'KM',
                                            border:
                                            OutlineInputBorder()
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                child: Column(
                                  children: [
                                    const ListTile(
                                      title: Text("Całkowity koszt serwisu"),
                                      subtitle: Text(
                                          "Wpisz ile zapłaciłeś za serwis pojazdu"),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: _kosztSerwisu,
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
                              Card(
                                child: Column(
                                  children: [
                                    const ListTile(
                                      title: Text("Interwał serwisu"),
                                      subtitle: Text(
                                          "Wybierz przypomnienie o kolejnej serwisie"),
                                    ),
                                    CheckboxListTile(
                                      title: const Text(
                                          "Po ilości przejechanych km"),
                                      value: przypomnienieKm,
                                      onChanged: (newValue) {
                                        setState(() {
                                          przypomnienieKm = newValue!;
                                        });
                                      },
                                    ),
                                    przypomnienieKm
                                        ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller:
                                        _przebiegKolejnejSerwisu,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .allow(RegExp(r'^\d+')),
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                            decimal: false),
                                        decoration: const InputDecoration(
                                            labelText:
                                            'Podaj ilość km do kolejnego serwisu',
                                            border:
                                            OutlineInputBorder()
                                        ),
                                      ),
                                    )
                                        : Container(),
                                    CheckboxListTile(
                                      title: const Text(
                                          "Wybierz datę przypomnienia o następnym serwisie"),
                                      value: przypomnienieMiesiace,
                                      onChanged: (newValue) {
                                        setState(() {
                                          przypomnienieMiesiace = newValue!;
                                        });
                                      },
                                    ),
                                    przypomnienieMiesiace
                                        ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment:
                                              Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    8.0),
                                                child: Text(
                                                    "Ustawiona data przypomnienia następnego serwisu to: ${_dataKolejnegoSerwisu.day}.${_dataKolejnegoSerwisu.month}.${_dataKolejnegoSerwisu.year}"),
                                              ),
                                            ),
                                            FilledButton(
                                              onPressed: () async {
                                                DateTime? nowaWybranaData =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                    _dateTime,
                                                    firstDate:
                                                    //set date from _dateTime
                                                    DateTime(
                                                        _dateTime
                                                            .year,
                                                        _dateTime
                                                            .month,
                                                        _dateTime
                                                            .day),
                                                    lastDate:
                                                    DateTime(2100));
                                                if (nowaWybranaData ==
                                                    null) {
                                                  return;
                                                } else {
                                                  setState(() {
                                                    _dataKolejnegoSerwisu =
                                                        nowaWybranaData;
                                                  });
                                                }
                                              },
                                              child: const Padding(
                                                padding:
                                                EdgeInsets.all(10.0),
                                                child: Text(
                                                    "Wybierz Datę kolejnego serwisu"),
                                              ),
                                            ),
                                          ],
                                        ))
                                        : Container(),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FilledButton(
                                onPressed: () {
                                  if (_tytulSerwisu.text.isEmpty) {
                                    AlertDialog alert = AlertDialog(
                                      title: const Text("Błąd"),
                                      content:
                                      const Text("Wpisz nazwę serwisu"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("OK"))
                                      ],
                                    );
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alert;
                                        });
                                    return;
                                  }

                                  if (_dodajSerwisKey.currentState!
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
                                  child: Text("Dodaj wpis serwisu"),
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
