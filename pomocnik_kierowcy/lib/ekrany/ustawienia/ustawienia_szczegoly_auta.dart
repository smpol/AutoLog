import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UstawieniaSzczegolowAuta extends StatefulWidget {
  const UstawieniaSzczegolowAuta({super.key});

  @override
  State<UstawieniaSzczegolowAuta> createState() =>
      _UstawieniaSzczegolowAutaState();
}

class _UstawieniaSzczegolowAutaState extends State<UstawieniaSzczegolowAuta> {
  final nazwaAuta = TextEditingController();
  final _nazwaAutaFormKey = GlobalKey<FormState>();

  final tabliceRejestracyjne = TextEditingController();
  final _tabliceRejestracyjneFormKey = GlobalKey<FormState>();

  final numerVIN = TextEditingController();
  final _numerVINFormKey = GlobalKey<FormState>();

  void updateNazwaAuta() async {
    var box = await Hive.openBox("szczegoly_auta");
    box.putAt(0, nazwaAuta.text);
  }

  void updateTabliceRejestracyjne() async {
    var box = await Hive.openBox("szczegoly_auta");
    box.putAt(1, tabliceRejestracyjne.text);
  }

  void updateNumerVIN() async {
    var box = await Hive.openBox("szczegoly_auta");
    box.putAt(2, numerVIN.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Szczegóły pojazdu"),
        ),
        body: (Material(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Form(
                              key: _nazwaAutaFormKey,
                              child: AlertDialog(
                                title: const Text("Marka pojazdu"),
                                content: TextFormField(
                                  controller: nazwaAuta,
                                  decoration: InputDecoration(
                                      labelText: "Marka pojazdu",
                                      // hintText: (Hive.box("szczegoly_auta")
                                      //             .getAt(0) !=
                                      //         "")
                                      //     ? Hive.box("szczegoly_auta").getAt(0)
                                      //     : "Wpisz markę pojazdu",
                                      border: const OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Wpisz markę pojazdu";
                                    }
                                    return null;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Anuluj")),
                                  TextButton(
                                      onPressed: () {
                                        if (_nazwaAutaFormKey.currentState!
                                            .validate()) {
                                          updateNazwaAuta();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text("Zapisz"))
                                ],
                              ),
                            );
                          });
                    },
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.car_repair),
                              title: Text("Marka pojazdu"),
                              subtitle: Text(
                                  "Możesz wpisać nazwę własną lub na przykład markę i model pojazdu")),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Form(
                              key: _tabliceRejestracyjneFormKey,
                              child: AlertDialog(
                                title: const Text("Numer rejestracyjny"),
                                content: TextFormField(
                                  controller: tabliceRejestracyjne,
                                  decoration: InputDecoration(
                                      labelText: "Numer rejestracyjny",
                                      // hintText: (Hive.box("szczegoly_auta")
                                      //             .getAt(1) !=
                                      //         "")
                                      //     ? Hive.box("szczegoly_auta").getAt(1)
                                      //     : "Wpisz numer rejestracyjny Twojego pojazdu",
                                      border: const OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Wpisz numer rejestracyjny Twojego pojazdu";
                                    }
                                    return null;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Anuluj")),
                                  TextButton(
                                      onPressed: () {
                                        if (_tabliceRejestracyjneFormKey
                                            .currentState!
                                            .validate()) {
                                          updateTabliceRejestracyjne();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text("Zapisz"))
                                ],
                              ),
                            );
                          });
                    },
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.edit_document),
                              title: Text("Numer rejestracyjny"),
                              subtitle: Text(
                                  "Tutaj wpiszesz numery rejestracyjne Twojego pojazdu")),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Form(
                              key: _numerVINFormKey,
                              child: AlertDialog(
                                title: const Text("Numer VIN"),
                                content: TextFormField(
                                  controller: numerVIN,
                                  decoration: InputDecoration(
                                      labelText: "Numer VIN",
                                      // hintText: (Hive.box("szczegoly_auta")
                                      //             .getAt(2) !=
                                      //         "")
                                      //     ? Hive.box("szczegoly_auta").getAt(2)
                                      //     : "Wpisz numer VIN Twojego pojazdu",
                                      border: const OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Wpisz numer VIN";
                                    }
                                    return null;
                                  },
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Anuluj")),
                                  TextButton(
                                      onPressed: () {
                                        if (_numerVINFormKey.currentState!
                                            .validate()) {
                                          updateNumerVIN();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text("Zapisz"))
                                ],
                              ),
                            );
                          });
                    },
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.car_crash),
                              title: Text("Numer VIN"),
                              subtitle: Text(
                                  "Tutaj wpiszesz numer VIN Twojego pojazdu")),
                        ),
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
