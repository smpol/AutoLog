
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UstawieniaUsuwanie extends StatelessWidget {
  const UstawieniaUsuwanie({super.key});



  void deleteAll() async {
    debugPrint("Delete All ustawienia");
    var box = await Hive.openBox("tankowanie");
    box.clear();
    box = await Hive.openBox("naprawy");
    box.clear();
  }

  void deleteTankowanie() async {
    var box = await Hive.openBox("tankowanie");
    box.clear();
  }

  void deleteSerwisy() async {
    var box = await Hive.openBox("naprawy");
    box.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Usuwanie wpisów"),
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
                            return AlertDialog(
                              title: const Text("Usuwanie danych"),
                              content: const Text("Czy na pewno chcesz usunąć wszystkie dane?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Nie")
                                ),
                                TextButton(
                                    onPressed: () {
                                      deleteAll();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Tak")
                                ),
                              ],
                            );
                          }
                      );
                    },
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.delete_forever),
                              title: Text("Usuń wszystkie dane"),
                              subtitle: Text("Operacja ta usunie wszystkie wpisy o tankowaniu i serwisach. Operacja nie jest odwracalna")
                          ),
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
                            return AlertDialog(
                              title: const Text("Usuwanie danych"),
                              content: const Text("Czy na pewno chcesz usunąć wszystkie wpisy o tankowaniu?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Nie")
                                ),
                                TextButton(
                                    onPressed: () {
                                      deleteTankowanie();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Tak")
                                ),
                              ],
                            );
                          }
                      );
                    },
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text("Usuń wszystkie wpisy o tankowaniu"),
                              subtitle: Text("Operacja ta usunie wszystkie wpisy o tankowaniu. Operacja nie jest odwracalna")
                          ),
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
                            return AlertDialog(
                              title: const Text("Usuwanie danych"),
                              content: const Text("Czy na pewno chcesz usunąć wszystkie wpisy o serwisach?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Nie")
                                ),
                                TextButton(
                                    onPressed: () {
                                      deleteSerwisy();
                                      Navigator.pop(context);

                                    },
                                    child: const Text("Tak")
                                ),
                              ],
                            );
                          }
                      );
                    },
                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text("Usuń wszystkie wpisy o serwisach"),
                              subtitle: Text("Operacja ta usunie wszystkie wpisy o serwisach. Operacja nie jest odwracalna")
                          ),
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
