import 'package:flutter/material.dart';
import 'package:pomocnik_kierowcy/ekrany/ustawienia/ustawienia_powiadomienia.dart';
import 'package:pomocnik_kierowcy/ekrany/ustawienia/ustawienia_szczegoly_auta.dart';
import 'package:pomocnik_kierowcy/ekrany/ustawienia/ustawienia_usuwanie.dart';

class Ustawienia extends StatelessWidget {
  const Ustawienia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ustawienia"),
        ),
        body: (Material(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const UstawieniaSzczegolowAuta()));
                    },
                    child: const Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.car_crash),
                          title: Text("Szczegóły pojazdu"),
                          subtitle: Text(
                              "Ustawisz tutaj szczegóły pojazdu (numer rejestracyjny, numer VIN, markę)"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const UstawieniaPowiadomienia()));
                    },
                    child: const Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.notifications),
                          title: Text("Ustawienia przypomnień"),
                          subtitle: Text(
                              "Ustaw swoje preferencje dot. wyświetlana na stronie głównej serwisu"),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const UstawieniaUsuwanie()));
                    },
                    child: const Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text("Usuwanie wpisów"),
                          subtitle: Text(
                              "Tutaj usuniesz wpisy z aplikacji (wszystkie, tankowania lub serwisu)"),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )));
  }
}
