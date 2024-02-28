import 'package:flutter/material.dart';
import 'package:pomocnik_kierowcy/ekrany/dodanie/dodanie_naprawa.dart';
import 'package:pomocnik_kierowcy/ekrany/dodanie/dodanie_paliwo.dart';
import 'package:pomocnik_kierowcy/inne/reklama.dart';

class DodanieWpisu extends StatelessWidget {
  const DodanieWpisu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Dodanie wpisu"),
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
        //color: Colors.amberAccent,
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DodajPaliwo()));
                          },
                          child: const Column(
                            children: [
                              ListTile(
                                title: Text("Paliwo"),
                                subtitle: Text(
                                    "Tutaj zapiszesz wpis dotyczący tankowania"),
                                leading: Icon(Icons.local_gas_station),
                              )
                            ],
                          ),
                        ),
                      ),
                      Card(
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DodajSerwis()));
                          },
                          child: const Column(
                            children: [
                              ListTile(
                                title: Text("Obsługa Pojazdu"),
                                subtitle: Text(
                                    "Tutaj zapiszesz wpis dotyczący serwisu pojazdu"),
                                leading: Icon(Icons.home_repair_service),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            const ReklamaBaner(),
          ],
        ),
      ),
    );
  }
}
