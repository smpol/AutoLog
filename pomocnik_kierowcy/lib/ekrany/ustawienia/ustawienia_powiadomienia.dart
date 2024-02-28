import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UstawieniaPowiadomienia extends StatefulWidget {
  const UstawieniaPowiadomienia({super.key});

  @override
  State<UstawieniaPowiadomienia> createState() =>
      _UstawieniaPowiadomieniaState();
}

class _UstawieniaPowiadomieniaState extends State<UstawieniaPowiadomienia> {
  void modifyIloscDniPrzypomnienia(int iloscDni) async {
    final box = await Hive.openBox("ustawienia");
    box.putAt(0, iloscDni);
  }

  void modifyIloscKilometrowPrzypomnienia(int iloscKilometrow) async {
    final box = await Hive.openBox("ustawienia");
    box.putAt(1, iloscKilometrow);
  }

  final box = Hive.openBox("ustawienia");

  final _iloscDniKey = GlobalKey<FormState>();

  final _iloscKilometrowKey = GlobalKey<FormState>();

  final _iloscDni = TextEditingController();

  final _iloscKilometrow = TextEditingController();

  String iloscDni = "7";

  String iloscKilometrow = "1000";

  Future<void> readAll() async {
    final value = await box;
    iloscDni = value.get("iloscDniPrzypomnienia").toString();
    iloscKilometrow = value.get("iloscKilometrowPrzypomnienia").toString();
  }

  @override
  Widget build(BuildContext context) {
    readAll();
    debugPrint(iloscDni);
    debugPrint(iloscKilometrow);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Preferencje powiadomień"),
        ),
        body: (Material(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      debugPrint("kliknięto przycisk");
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Form(
                              key: _iloscDniKey,
                              child: AlertDialog(
                                title: const Text("Wprowadź wartość"),
                                content: SizedBox(
                                  height: 100,
                                  //width = width of device
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: [
                                      Text("Aktualna wartość to: $iloscDni"),
                                      TextFormField(
                                        controller: _iloscDni,
                                        decoration: const InputDecoration(
                                            labelText:
                                                "Ile dni przed przypominać o serwisie?",
                                            border: OutlineInputBorder()),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Wprowadź wartość";
                                          }
                                          if (int.parse(value) < 1) {
                                            return "Minimalna wartość to 1";
                                          }
                                          return null;
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+')),
                                        ],
                                        //ad regex here
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Anuluj")),
                                  TextButton(
                                      onPressed: () {
                                        //deleteAll();
                                        // Navigator.pop(context);
                                        if (_iloscDniKey.currentState!
                                            .validate()) {
                                          modifyIloscDniPrzypomnienia(
                                              int.parse(_iloscDni.text));

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Zapisano zmiany')));
                                        }
                                        setState(() {
                                          iloscDni = _iloscDni.text;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Zapisz")),
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
                              leading: Icon(Icons.calendar_month_rounded),
                              title:
                                  Text("Ile dni przed przypominać o serwisie?"),
                              subtitle: Text(
                                  "Ustawisz tutaj ile dni przed przypominać o serwisie")),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      debugPrint("kliknięto przycisk");
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Form(
                              key: _iloscKilometrowKey,
                              child: AlertDialog(
                                title: const Text(
                                    "Wpisz za ile kilometrów przypominać o serwisie"),
                                content: Form(
                                  child: SizedBox(
                                    height: 100,
                                    //width = width of device
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: [
                                        Text(
                                            "Aktualna wartość to: ${iloscKilometrow}km"),
                                        TextFormField(
                                          controller: _iloscKilometrow,
                                          decoration: const InputDecoration(
                                              labelText:
                                                  "Ile kilometrów przed przypominać o serwisie?",
                                              border: OutlineInputBorder()),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Wprowadź wartość";
                                            }
                                            if (int.parse(value) < 1) {
                                              return "Minimalna wartość to 1";
                                            }
                                            return null;
                                          },
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+')),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Anuluj")),
                                  TextButton(
                                      onPressed: () {
                                        // //deleteAll();
                                        // Navigator.pop(context);
                                        if (_iloscKilometrowKey.currentState!
                                            .validate()) {
                                          modifyIloscKilometrowPrzypomnienia(
                                              int.parse(_iloscKilometrow.text));
                                          setState(() {
                                            iloscKilometrow =
                                                _iloscKilometrow.text;
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Zapisano zmiany')));
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text("Zapisz")),
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
                              leading: Icon(Icons.notifications_active_rounded),
                              title: Text(
                                  "Ile kilometrów przed przypominać o serwisie?"),
                              subtitle: Text(
                                  "Ustawisz tutaj ile kilometrów przed przypominać o serwisie")),
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
