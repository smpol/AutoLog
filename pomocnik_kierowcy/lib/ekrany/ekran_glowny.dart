import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomocnik_kierowcy/inne/notification_service.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:pomocnik_kierowcy/ekrany/dodanie_wpisu.dart';
import 'package:pomocnik_kierowcy/ekrany/szczegoly_pojazdu.dart';
import 'package:pomocnik_kierowcy/inne/reklama.dart';
import 'package:pomocnik_kierowcy/ekrany/ustawienia.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async';

String liczba = "";
int currentPageIndex = 0;

class TankowanieWpis {
  final String nazwaStacji;
  final DateTime dataTankowania;
  final String iloscPaliwa;
  final String przebieg;
  final String kosztTankowania;
  final String notatkaTankowania;

  TankowanieWpis(this.nazwaStacji, this.dataTankowania, this.iloscPaliwa,
      this.przebieg, this.kosztTankowania, this.notatkaTankowania);
}

class SerwisWpis {
  final String tytulSerwisu;
  final String opisSerwisu;
  final String przebieg;
  final String kosztSerwisu;
  final DateTime dataSerwisu;
  final DateTime przypomnienieData;
  final double przypomnienieKm;

  SerwisWpis(
      this.tytulSerwisu,
      this.opisSerwisu,
      this.przebieg,
      this.kosztSerwisu,
      this.dataSerwisu,
      this.przypomnienieData,
      this.przypomnienieKm);
}

Future<List<TankowanieWpis>> fetchDataPaliwo() async {
  var box = await Hive.openBox("tankowanie");
  List<TankowanieWpis> lista = [];
  for (int i = 0; i < box.length; i++) {
    lista.add(TankowanieWpis(
        box.getAt(i)["nazwa_stacji"],
        box.getAt(i)["data_tankowania"],
        box.getAt(i)["ilosc_paliwa"],
        box.getAt(i)["przebieg"],
        box.getAt(i)["koszt_tankowania"],
        box.getAt(i)["notatka_tankowania"]));
  }

  //sortowanie listy po dacie malejąco
  lista.sort((a, b) => b.dataTankowania.compareTo(a.dataTankowania));
  return lista;
}

Future<List<SerwisWpis>> fetchDataSerwisu() async {
  var box = await Hive.openBox("naprawy");
  List<SerwisWpis> lista = [];
  for (int i = 0; i < box.length; i++) {
    lista.add(SerwisWpis(
        box.getAt(i)["tytul_naprawy"],
        box.getAt(i)["opis_naprawy"],
        box.getAt(i)["przebieg"],
        box.getAt(i)["koszt_naprawy"],
        box.getAt(i)["data_naprawy"],
        box.getAt(i)["przypomnienie_miesiace"],
        box.getAt(i)["przypomnienie_km"]));
  }
  //sortowanie listy po dacie
  lista.sort((a, b) => a.dataSerwisu.compareTo(b.dataSerwisu));
  return lista;
}

Future<int> znajdzNajwiekszyPrzebieg() async {
  int temp = 0;
  String temp2 = "";
  var box = await Hive.openBox("tankowanie");
  for (int i = 0; i < box.length; i++) {
    temp2 = box.getAt(i)["przebieg"].toString();
    if (int.parse(temp2) > temp) {
      temp = int.parse(temp2);
    }
  }
  box = await Hive.openBox("naprawy");
  for (int i = 0; i < box.length; i++) {
    temp2 = box.getAt(i)["przebieg"].toString();
    if (int.parse(temp2) > temp) {
      temp = int.parse(temp2);
    }
  }
  return temp;
}

bool czyJestWpisSerwisowyZblizajacySie() {
  int liczba = 0;

  var box = Hive.box("naprawy");
  for (int i = 0; i < box.length; i++) {
    if (box.getAt(i)["przypomnienie_miesiace"].isAfter(DateTime(2000)) ||
        box.getAt(i)["przypomnienie_km"] > 0) {
      liczba++;
    }
  }
  if (liczba > 0) {
    return true;
  } else {
    return false;
  }
}

void deleteAll() async {
  var box = await Hive.openBox("tankowanie");
  box.clear();
  box = await Hive.openBox("naprawy");
  box.clear();
}

Future<void> update_powiadomienia() async {
  //sprawdz czy przyznano uprawnienia
  if (await NotificationService()
          .notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ==
      false) {
    print("Nie przyznano uprawnień");
    return;
  }
  print("Wyczyszone powiadomienia");
  NotificationService().notificationsPlugin.cancelAll();
  var box = await Hive.openBox("naprawy");
  var boxUstawienia = await Hive.openBox("ustawienia");
  List<SerwisWpis> lista = [];
  //znajdz wszystkie wpisy ktore maja przypomnienie i datę po 2001
  for (int i = 0; i < box.length; i++) {
    if (box.getAt(i)["przypomnienie_miesiace"].isAfter(DateTime(2000))) {
      lista.add(SerwisWpis(
          box.getAt(i)["tytul_naprawy"],
          box.getAt(i)["opis_naprawy"],
          box.getAt(i)["przebieg"],
          box.getAt(i)["koszt_naprawy"],
          box.getAt(i)["data_naprawy"],
          //date przypomnienie miesiace odejmij ilosc dni przypomnienia z boxu ustawienia oraz ustaw date na godzine 12:00
          box.getAt(i)["przypomnienie_miesiace"].subtract(
              Duration(days: boxUstawienia.get("iloscDniPrzypomnienia"))),
          box.getAt(i)["przypomnienie_km"]));
    }
  }
  //usuń duplikaty
  lista = lista.toSet().toList();
  if (lista.isEmpty != true) {
    for (int i = 0; i < lista.length; i++) {
      DateTime temp = lista[i].przypomnienieData;
      //ustaw date na godzine 12:00
      temp = DateTime(temp.year, temp.month, temp.day, 12, 0, 0);
      if (temp.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
            id: i,
            title: "AutoLog",
            body: "Zbliża się termin serwisu: ${lista[i].tytulSerwisu}!",
            scheduledNotificationDateTime: temp);
        print("Ustawiono powiadomienie o godzinie: ${temp.toString()}");
      }
    }
  }
}

class EkranGlowny extends StatefulWidget {
  const EkranGlowny({super.key});

  @override
  State<EkranGlowny> createState() => _EkranGlownyState();
}

class _EkranGlownyState extends State<EkranGlowny> {
  @override
  void initState() {
    super.initState();
    //check if it is first run
    if (Hive.box("ustawienia").get("firstRun") == null) {
      Hive.box("ustawienia").put("firstRun", false);
      //showcase
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ShowCaseWidget.of(context).startShowCase(
          [
            _ekranGlownyKey,
            _menuPrzyciskKey,
            _dolneTankowanieGlownaKey,
            _dolneObslugaPojazduGlownaKey,
            _przyciskDodajKey,
          ],
        ),
      );
    }
  }

  final _dolneTankowanieGlownaKey = GlobalKey();
  final _dolneObslugaPojazduGlownaKey = GlobalKey();
  final _przyciskDodajKey = GlobalKey();
  final _ekranGlownyKey = GlobalKey();
  final _menuPrzyciskKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Ekran główny"),
          leading: Builder(builder: (context) {
            return Showcase(
              key: _menuPrzyciskKey,
              description:
                  'Tutaj znajdziesz ustawienia aplikacji oraz szczegóły pojazdu. Tam ustawisz m.in. preferencje dotyczące przypomnień o zbliżającym się serwisie',
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          })),
      body: [
        pierwszaStrona(),
        drugaStrona(),
        trzeciaStrona(),
      ][currentPageIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Szczegóły pojazdu'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SzczegolyPojazdu()),
                );
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ustawienia'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Ustawienia()),
                );
                setState(() {});
              },
            )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Showcase(
          key: _przyciskDodajKey,
          description:
              'Tutaj możesz dodać wpis o tankowaniu lub obsłudze pojazdu',
          //zwieksz promien
          // tooltipBorderRadius: BorderRadius.circular(20),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // Add your onPressed code here!
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DodanieWpisu()),
              );
              setState(() {});
            },
            label: const Text('Dodaj'),
            icon: const Icon(Icons.add),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            const NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Strona Główna',
            ),
            Showcase(
              key: _dolneTankowanieGlownaKey,
              description: 'Tutaj możesz zobaczyć wszystkie wpisy o tankowaniu',
              child: const NavigationDestination(
                icon: Icon(Icons.local_gas_station_outlined),
                selectedIcon: Icon(Icons.local_gas_station),
                label: 'Tankowanie',
              ),
            ),
            Showcase(
              key: _dolneObslugaPojazduGlownaKey,
              description:
                  'Tutaj możesz zobaczyć swoje wszystkie wpisy o obsłudze pojazdu',
              child: const NavigationDestination(
                selectedIcon: Icon(Icons.garage),
                icon: Icon(Icons.garage_outlined),
                label: 'Obsługa Pojazdu',
              ),
            ),
          ]),
    );
  }

  Column pierwszaStrona() {
    update_powiadomienia();
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Showcase(
              key: _ekranGlownyKey,
              description:
                  'Witaj w aplikacji! To jest twój kokpit, gdzie znajdziesz informacje o ostatnim tankowaniu, szczegóły pojazdu i nadchodzące serwisy',
              child: Column(
                children: [
                  Card(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      FutureBuilder(
                          future: znajdzNajwiekszyPrzebieg(),
                          builder: (context, snapshot) {
                            //check if snapshot has data and przebieg bigger than 0
                            if (snapshot.hasData && snapshot.data! > 0) {
                              return ListTile(
                                  title: const Text("Witaj Kierowco! 🚗",
                                      style: TextStyle(fontSize: 30)),
                                  subtitle: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "Ostatni przebieg pojazdu to: ${snapshot.data} km"),
                                      ),
                                      if (Hive.box("szczegoly_auta").getAt(0) !=
                                              null &&
                                          Hive.box("szczegoly_auta").getAt(0) !=
                                              "")
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              "Marka pojazdu: ${Hive.box("szczegoly_auta").getAt(0)}"),
                                        ),
                                      if (Hive.box("szczegoly_auta").getAt(1) !=
                                              null &&
                                          Hive.box("szczegoly_auta").getAt(1) !=
                                              "")
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              "Numer rejestracyjny: ${Hive.box("szczegoly_auta").getAt(1)}"),
                                        ),
                                      if (Hive.box("szczegoly_auta").getAt(2) !=
                                              null &&
                                          Hive.box("szczegoly_auta").getAt(2) !=
                                              "")
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                              "Numer vin: ${Hive.box("szczegoly_auta").getAt(2)}"),
                                        ),
                                    ],
                                  ));
                            } else {
                              return ListTile(
                                title: const Text("Witaj Kierowco! 🚗",
                                    style: TextStyle(fontSize: 30)),
                                subtitle: Column(
                                  children: [
                                    if (Hive.box("szczegoly_auta").getAt(0) !=
                                            null &&
                                        Hive.box("szczegoly_auta").getAt(0) !=
                                            "")
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "Marka pojazdu: ${Hive.box("szczegoly_auta").getAt(0)}"),
                                      ),
                                    if (Hive.box("szczegoly_auta").getAt(1) !=
                                            null &&
                                        Hive.box("szczegoly_auta").getAt(1) !=
                                            "")
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "Numer rejestracyjny: ${Hive.box("szczegoly_auta").getAt(1)}"),
                                      ),
                                    if (Hive.box("szczegoly_auta").getAt(2) !=
                                            null &&
                                        Hive.box("szczegoly_auta").getAt(2) !=
                                            "")
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "Numer vin: ${Hive.box("szczegoly_auta").getAt(2)}"),
                                      ),
                                  ],
                                ),
                              );
                            }
                          }),
                      // ListTile(
                      //   subtitle: Column(
                      //     children: [
                      //       if (Hive.box("szczegoly_auta").getAt(0) != null &&
                      //           Hive.box("szczegoly_auta").getAt(0) != "")
                      //         Text(
                      //             "Nazwa auta: ${Hive.box("szczegoly_auta").getAt(0)}"),
                      //       if (Hive.box("szczegoly_auta").getAt(1) != null &&
                      //           Hive.box("szczegoly_auta").getAt(1) != "")
                      //         Text(
                      //             "Numer rejestracyjny: ${Hive.box("szczegoly_auta").getAt(1)}"),
                      //       if (Hive.box("szczegoly_auta").getAt(2) != null &&
                      //           Hive.box("szczegoly_auta").getAt(2) != "")
                      //         Text(
                      //             "Numer vin: ${Hive.box("szczegoly_auta").getAt(2)}"),
                      //     ],
                      //   ),
                      // )
                    ]),
                  ),
                  if (Hive.box("tankowanie").isEmpty &&
                      Hive.box("naprawy").isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text("Witaj w aplikacji!",
                                  style: TextStyle(fontSize: 25)),
                              leading: Icon(Icons.waving_hand),
                            ),
                            ListTile(
                              title: Text(
                                  "Aby rozpocząć dodaj wpis za pomocą przycisku Dodaj w prawym dolnym rogu ekranu"),
                              leading: Icon(Icons.info),
                            ),
                            ListTile(
                              subtitle: Text(
                                  "Dodane wpisy będą wyświetlać się na ekranie głównym aplikacji (ostatni wpis tankowania lub zbliżające się serwisy pojazdu)"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (Hive.box("tankowanie").length > 0)
                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text("Ostatni wpis tankowania:",
                                style: TextStyle(fontSize: 25)),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FutureBuilder(
                              future: fetchDataPaliwo(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.isEmpty) {
                                    return const ListTile(
                                      title: Text(
                                        "Brak danych, dodaj wpis przyciskiem Dodaj",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      leading: Icon(Icons.info),
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Text(
                                              "Stacja: ${snapshot.data!.first.nazwaStacji}"),
                                          subtitle: Text(
                                              "Data tankowania: ${snapshot.data!.first.dataTankowania.day}.${snapshot.data!.last.dataTankowania.month}.${snapshot.data!.last.dataTankowania.year}"),
                                          leading: const Icon(
                                              Icons.local_gas_station),
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.attach_money),
                                          title: Text(
                                              "Koszt tankowania: ${snapshot.data!.first.kosztTankowania} zł"),
                                          subtitle: Text(
                                              "Ilość paliwa: ${snapshot.data!.first.iloscPaliwa} litrów"),
                                        )
                                      ],
                                    );
                                  }
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (czyJestWpisSerwisowyZblizajacySie())
                    Card(
                      child: Column(
                        children: [
                          const ListTile(
                            title: Text("Zbliżające się serwisy:",
                                style: TextStyle(fontSize: 25)),
                          ),
                          FutureBuilder(
                              future: znajdzNajwiekszyPrzebieg(),
                              builder: (context, snapshot) {
                                List<SerwisWpis> lista = [];
                                List<SerwisWpis> listaFinalna = [];
                                var box = Hive.box("naprawy");
                                var boxUstawienia = Hive.box("ustawienia");
                                for (int i = 0; i < box.length; i++) {
                                  lista.add(SerwisWpis(
                                      box.getAt(i)["tytul_naprawy"],
                                      box.getAt(i)["opis_naprawy"],
                                      box.getAt(i)["przebieg"],
                                      box.getAt(i)["koszt_naprawy"],
                                      box.getAt(i)["data_naprawy"],
                                      box.getAt(i)["przypomnienie_miesiace"],
                                      box.getAt(i)["przypomnienie_km"]));
                                }
                                for (int i = 0; i < lista.length; i++) {
                                  if (lista[i] != null) {
                                    if (lista[i]
                                        .przypomnienieData
                                        .isAfter(DateTime(2000))) {
                                      if (lista[i]
                                              .przypomnienieData
                                              .difference(DateTime.now())
                                              .inDays <=
                                          boxUstawienia
                                              .get("iloscDniPrzypomnienia")) {
                                        listaFinalna.add(lista[i]);
                                      }
                                    }
                                    if (lista[i].przypomnienieKm > -1) {
                                      if (lista[i].przypomnienieKm -
                                              int.parse(lista[i].przebieg) <=
                                          boxUstawienia.get(
                                              "iloscKilometrowPrzypomnienia")) {
                                        listaFinalna.add(lista[i]);
                                      }
                                    }
                                  }
                                }
                                //usun duplikaty
                                listaFinalna = listaFinalna.toSet().toList();

                                if (listaFinalna.isEmpty) {
                                  return const ListTile(
                                    title: Text(
                                      "Ufff 😮‍💨, wszystko w porządku! Na razie nie ma żadnych zbliżających się serwisów 🚗",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    leading: Icon(Icons.info),
                                  );
                                }
                                final najwiekszyPrzebieg = snapshot.data;

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listaFinalna.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          "Serwis: ${listaFinalna[index].tytulSerwisu}"),
                                      subtitle: Column(
                                        children: [
                                          if (listaFinalna[index]
                                              .przypomnienieData
                                              .isAfter(DateTime(2000)))
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Container(
                                                child: (listaFinalna[index]
                                                            .przypomnienieData
                                                            .difference(
                                                                DateTime.now())
                                                            .inDays <=
                                                        0)
                                                    ? Text(
                                                        "Data nastepnego serwisu: ${listaFinalna[index].przypomnienieData.day}.${listaFinalna[index].przypomnienieData.month}.${listaFinalna[index].przypomnienieData.year} Przekroczono termin o ${listaFinalna[index].przypomnienieData.difference(DateTime.now()).inDays.abs()} dni",
                                                        style: const TextStyle(
                                                            color: Colors.red))
                                                    : Text(
                                                        "Data nastepnego serwisu: ${listaFinalna[index].przypomnienieData.day}.${listaFinalna[index].przypomnienieData.month}.${listaFinalna[index].przypomnienieData.year} Pozostało: ${listaFinalna[index].przypomnienieData.difference(DateTime.now()).inDays} dni"),
                                              ),
                                            ),
                                          //check if przypomnieniekm is not null and bigger than 0
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: [
                                                if (najwiekszyPrzebieg != null)
                                                  if (najwiekszyPrzebieg > 0)
                                                    Column(
                                                      children: [
                                                        if (listaFinalna[index]
                                                                .przypomnienieKm >
                                                            0)
                                                          Column(
                                                            children: [
                                                              if ((int.parse(listaFinalna[
                                                                              index]
                                                                          .przebieg) +
                                                                      listaFinalna[
                                                                              index]
                                                                          .przypomnienieKm <
                                                                  (najwiekszyPrzebieg
                                                                      .toInt())))
                                                                Text(
                                                                    "Interwał: ${listaFinalna[index].przypomnienieKm} km, Przekroczono przebieg o ${int.parse(listaFinalna[index].przebieg) + listaFinalna[index].przypomnienieKm - (najwiekszyPrzebieg.toInt())} km",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .red))
                                                              else
                                                                Text(
                                                                    "Interwał: ${listaFinalna[index].przypomnienieKm} km, Pozostało: ${(int.parse(listaFinalna[index].przebieg) + listaFinalna[index].przypomnienieKm) - ((najwiekszyPrzebieg.toInt()))} km"),
                                                            ],
                                                          )
                                                        else
                                                          Container(),
                                                      ],
                                                    ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      leading: const Icon(Icons.garage),
                                    );
                                  },
                                );
                              })
                        ],
                      ),
                    ),
                  // Card(
                  //   child: Column(
                  //     children: [
                  //       const ListTile(
                  //         title: Text("Debug Data"),
                  //       ),
                  //       Text(
                  //           "Ilosc dni przypomnienia: ${Hive.box("ustawienia").get("iloscDniPrzypomnienia")}"),
                  //       Text(
                  //           "Ilosc km przypomnienia: ${Hive.box("ustawienia").get("iloscKilometrowPrzypomnienia")}"),
                  //       FutureBuilder(
                  //           future: znajdzNajwiekszyPrzebieg(),
                  //           builder: (context, snapshot) {
                  //             if (snapshot.hasData) {
                  //               return Text(
                  //                   "Najwiekszy przebieg: ${snapshot.data}");
                  //             } else {
                  //               return Container();
                  //             }
                  //           }),
                  //       Text(
                  //           "Nazwa auta: ${Hive.box("szczegoly_auta").getAt(0)}"),
                  //       Text(
                  //           "Numer rejestracyjny: ${Hive.box("szczegoly_auta").getAt(1)}"),
                  //       Text(
                  //           "Numer vin: ${Hive.box("szczegoly_auta").getAt(2)}"),
                  //     ],
                  //   ),
                  // )
                  // Card(
                  //   child: Column(
                  //     children: [
                  //       TextButton(onPressed: NotificationService().showNotification, child: Text("Test powiadomienia")),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
        const ReklamaBaner(),
      ],
    );
  }

  Column drugaStrona() {
    update_powiadomienia();
    return Column(children: [
      Expanded(
        child: FutureBuilder(
          future: fetchDataPaliwo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Brak danych, dodaj wpis przyciskiem Dodaj",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_gas_station),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  "Stacja: ${snapshot.data![index].nazwaStacji}"),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  "Data tankowania: ${snapshot.data![index].dataTankowania.day}.${snapshot.data![index].dataTankowania.month}.${snapshot.data![index].dataTankowania.year}"),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.car_repair),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  "Ilość paliwa: ${snapshot.data![index].iloscPaliwa} litrów"),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  "Przebieg: ${snapshot.data![index].przebieg} km"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Row(
                                  children: [
                                    Icon(Icons.attach_money),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            "Koszt tankowania: ${snapshot.data![index].kosztTankowania}zł"),
                                      ),
                                    ),
                                  ],
                                )),
                                Expanded(
                                    child: Column(
                                  children: [
                                    if (index == snapshot.data!.length - 1)
                                      Row(
                                        children: [
                                          Icon(Icons.calculate),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text("Spalanie")),
                                                Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        "Pierwsze Tankowanie")),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    else
                                      Row(
                                        children: [
                                          Icon(Icons.calculate),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text("Spalanie")),
                                                if ((int.parse(snapshot
                                                                .data![
                                                                    index + 1]
                                                                .iloscPaliwa) *
                                                            100) /
                                                        (int.parse(snapshot
                                                                .data![index]
                                                                .przebieg) -
                                                            int.parse(snapshot
                                                                .data![
                                                                    index + 1]
                                                                .przebieg)) >
                                                    0)
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        "${(int.parse(snapshot.data![index + 1].iloscPaliwa) * 100) / (int.parse(snapshot.data![index].przebieg) - int.parse(snapshot.data![index + 1].przebieg))} l/100km"),
                                                  )
                                                else
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        "Błąd w liczeniu spalania"),
                                                  ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                  ],
                                ))
                              ],
                            ),
                          ),

                          //check if is a notatka
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (snapshot.data![index].notatkaTankowania != "")
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        AlertDialog alert = AlertDialog(
                                          title: const Text("Notatka"),
                                          content: Text(snapshot
                                              .data![index].notatkaTankowania),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Zamknij"),
                                            )
                                          ],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: const Text("Zobacz notatkę"),
                                    ),
                                  ),
                                ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // box.deleteAt(index);
                                    deleteWpisPaliwo(index);
                                    setState(() {});
                                    SnackBar snackBar = const SnackBar(
                                      content: Text("Usunięto wpis"),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  },
                                  child: const Text("Usuń wpis"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              }
            } else {
              return Container();
            }
          },
        ),
      ),
      const ReklamaBaner(),
    ]);
  }

  Column trzeciaStrona() {
    update_powiadomienia();
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: fetchDataSerwisu(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Brak danych, dodaj wpis przyciskiem Dodaj",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.home_repair_service),
                                        Expanded(
                                          child: Text(
                                              "Obsługa pojazdu:\n${snapshot.data![index].tytulSerwisu}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Icon(Icons.car_repair),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  "Przebieg: ${snapshot.data![index].przebieg} km"),
                                            ),
                                            if (snapshot.data![index]
                                                    .kosztSerwisu !=
                                                "")
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                    "Koszt: ${snapshot.data![index].kosztSerwisu} zł"),
                                              ),
                                            if (snapshot.data![index]
                                                    .kosztSerwisu ==
                                                "")
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child:
                                                    Text("Koszt: Brak danych"),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                      //check if przypomnienie_miesiace is empty
                                      ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  if (snapshot.data![index].przypomnienieData
                                      .isAfter(DateTime(1990)))
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.calendar_month_rounded),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                      "Nastpeny serwis jest: ${snapshot.data![index].przypomnienieData.day}.${snapshot.data![index].przypomnienieData.month}.${snapshot.data![index].przypomnienieData.year}"),
                                                ),
                                                if ((snapshot.data![index]
                                                        .przypomnienieData
                                                        .difference(
                                                            DateTime.now())
                                                        .inDays <=
                                                    0))
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        "Przekroczono termin o ${snapshot.data![index].przypomnienieData.difference(DateTime.now()).inDays.abs()} dni",
                                                        style: const TextStyle(
                                                            color: Colors.red)),
                                                  )
                                                else
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                        "Pozostało: ${snapshot.data![index].przypomnienieData.difference(DateTime.now()).inDays} dni"),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (snapshot.data![index].przypomnienieKm >
                                      -1)
                                    Expanded(
                                        child: Row(
                                      children: [
                                        const Icon(Icons.car_crash),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                    "Ustawiony interwał serwisu to: ${snapshot.data![index].przypomnienieKm} km"),
                                              ),
                                              FutureBuilder(
                                                future:
                                                    znajdzNajwiekszyPrzebieg(),
                                                builder: (context, snapshot2) {
                                                  if (snapshot2.hasData) {
                                                    if ((int.parse(snapshot
                                                                .data![index]
                                                                .przebieg) +
                                                            snapshot
                                                                .data![index]
                                                                .przypomnienieKm -
                                                            snapshot2.data!) >
                                                        0) {
                                                      return Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                            "Czyli za ${int.parse(snapshot.data![index].przebieg) + snapshot.data![index].przypomnienieKm - snapshot2.data!} km"),
                                                      );
                                                    } else {
                                                      return Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                            "Dokonaj jak najszybciej serwisu, przekroczono interwał o ${int.parse(snapshot.data![index].przebieg) + snapshot.data![index].przypomnienieKm - snapshot2.data!} km",
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                      );
                                                    }
                                                  } else {
                                                    return Container();
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                                ],
                              ),
                            ),
                            //check if is a opis and create button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (snapshot.data![index].opisSerwisu != "")
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        AlertDialog alert = AlertDialog(
                                          title: const Text("Opis"),
                                          content: Text(snapshot
                                              .data![index].opisSerwisu),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Zamknij"),
                                            )
                                          ],
                                        );
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          },
                                        );
                                      },
                                      child: const Text("Zobacz opis"),
                                    ),
                                  ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      onPressed: () {
                                        // box.deleteAt(index);
                                        deleteWpisSerwisu(index);
                                        setState(() {});
                                        SnackBar snackBar = const SnackBar(
                                          content: Text("Usunięto wpis"),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      child: const Text("Usuń wpis"),
                                    ),
                                  ),
                                ),
                                if (kIsWeb)
                                  Container()
                                else
                                  if (Platform.isAndroid || Platform.isIOS)
                                    if (snapshot.data![index].przypomnienieData
                                        .isAfter(DateTime(2001)))
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextButton(
                                            onPressed: () {
                                              final Event event = Event(
                                                title:
                                                    "Zbliżający serwis: ${snapshot.data![index].tytulSerwisu}",
                                                description:
                                                (snapshot.data![index]
                                                    .przypomnienieKm >1)? "Zbliżający się serwis: ${snapshot.data![index].tytulSerwisu} za ${snapshot.data![index].przypomnienieKm} km" : "",
                                                location: "",
                                                startDate: snapshot
                                                    .data![index].dataSerwisu,
                                                endDate: snapshot
                                                    .data![index].dataSerwisu,
                                              );
                                              Add2Calendar.addEvent2Cal(event);
                                            },
                                            child: const Text(
                                                "Dodaj do kalendarza"),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              } else {
                return Container();
              }
            },
          ),
        ),
        const ReklamaBaner(),
      ],
    );
  }

  void deleteWpisPaliwo(int index) async {
    var box = await Hive.openBox("tankowanie");
    box.deleteAt(index);
  }

  void deleteWpisSerwisu(int index) async {
    var box = await Hive.openBox("naprawy");
    box.deleteAt(index);
  }
}
