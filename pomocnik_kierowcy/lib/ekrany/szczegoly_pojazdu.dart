import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pomocnik_kierowcy/ekrany/ustawienia/ustawienia_szczegoly_auta.dart';
import 'package:pomocnik_kierowcy/inne/reklama.dart';

class SzczegolyPojazdu extends StatefulWidget {
  const SzczegolyPojazdu({super.key});

  @override
  State<SzczegolyPojazdu> createState() => _SzczegolyPojazduState();
}

class _SzczegolyPojazduState extends State<SzczegolyPojazdu> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szczegóły pojazdu"),
      ),
      body: Material(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text("Marka pojazdu, model"),
                              subtitle: (Hive.box("szczegoly_auta").getAt(0) != "")
                                  ? Text(Hive.box("szczegoly_auta").getAt(0))
                                  : const Text("Nie ustawiono"),
                            ),
                            Row(
                              children: [
                                if (Hive.box("szczegoly_auta").getAt(0) != "")
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text:
                                              Hive.box("szczegoly_auta").getAt(0)));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "Skopiowano Markę pojazdu do schowka")));
                                        },
                                        child: const Text("Kopiuj"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Share.share(Hive.box("szczegoly_auta")
                                              .getAt(0)
                                              .toString());},
                                        child: const Text("Udostępnij"),
                                      ),
                                    ],
                                  ),
                                TextButton(
                                    onPressed: () {
                                      //navigator push with update screen
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const UstawieniaSzczegolowAuta()))
                                          .whenComplete(() => setState(() {}));
                                    },
                                    child: const Text("Zmień")),
                              ],
                            )
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text("Numer rejestracyjny"),
                              subtitle: (Hive.box("szczegoly_auta").getAt(1) != "")
                                  ? Text(Hive.box("szczegoly_auta").getAt(1))
                                  : const Text("Nie ustawiono"),
                            ),
                            Row(
                              children: [
                                //copy button
                                if (Hive.box("szczegoly_auta").getAt(1) != "")
                                  TextButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text:
                                          Hive.box("szczegoly_auta").getAt(0)));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Skopiowano numer rejestracyjny schowka")));
                                    },
                                    child: const Text("Kopiuj"),
                                  ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const UstawieniaSzczegolowAuta()))
                                          .whenComplete(() => setState(() {}));
                                    },
                                    child: const Text("Zmień")),
                              ],
                            )
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text("Numer VIN"),
                              subtitle: (Hive.box("szczegoly_auta").getAt(2) != "")
                                  ? Text(Hive.box("szczegoly_auta").getAt(2))
                                  : const Text("Nie ustawiono"),
                            ),
                            Row(
                              children: [
                                //copy button
                                if (Hive.box("szczegoly_auta").getAt(2) != "")
                                  TextButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text:
                                          Hive.box("szczegoly_auta").getAt(0)));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Skopiowano numer VIN do schowka")));
                                    },
                                    child: const Text("Kopiuj"),
                                  ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const UstawieniaSzczegolowAuta()))
                                          .whenComplete(() => setState(() {}));
                                    },
                                    child: const Text("Zmień")),
                              ],
                            )
                          ],
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            const ListTile(
                              title: Text("Notatki"),
                              subtitle: Text(
                                  "Tutaj możesz wprowadzić dodatkowe notatki dotyczące pojazdu"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: Hive.box("szczegoly_auta").getAt(3),
                                onChanged: (value) {
                                  Hive.box("szczegoly_auta").putAt(3, value);
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Notatki',
                                ),
                                maxLines: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            const ReklamaBaner(),
          ],
        ),
      ),
    );
  }
}
