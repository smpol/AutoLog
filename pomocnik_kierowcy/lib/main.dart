// ignore_for_file: unused_import
//TODO - statystyki
//TODO - dodac https://firebase.google.com/products/crashlytics
// laczny koszt tankowania pojazdu

import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_timezone/flutter_timezone.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:pomocnik_kierowcy/inne/notification_service.dart";
import "package:showcaseview/showcaseview.dart";
import 'package:pomocnik_kierowcy/inne/reklama.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import "package:user_messaging_platform/user_messaging_platform.dart" as ump;
import "ekrany/ekran_glowny.dart";

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox("tankowanie");
  await Hive.openBox("naprawy");
  await Hive.openBox("szczegoly_auta");
  await initializeDefaultSettings();
  if (kIsWeb) {
  } else {
    if (Platform.isAndroid || Platform.isIOS) {
      updateConsent();
      WidgetsFlutterBinding.ensureInitialized();
      NotificationService().initNotification();
      MobileAds.instance.initialize();
      // MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
      //     testDeviceIds: ['7875217B84ABD6F545ED37114A946BCB']));
    }
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
  runApp(const MyApp());
}
void updateConsent() async {
  // Make sure to continue with the latest consent info.
  var info = await ump.UserMessagingPlatform.instance.requestConsentInfoUpdate();

  // Show the consent form if consent is required.
  if (info.consentStatus == ump.ConsentStatus.required) {
    // `showConsentForm` returns the latest consent info, after the consent from has been closed.
    info = await ump.UserMessagingPlatform.instance.showConsentForm();
  }
}

Future<void> initializeDefaultSettings() async {
  var box = await Hive.openBox("ustawienia");
  if (box.get("iloscDniPrzypomnienia") == null) {
    box.put("iloscDniPrzypomnienia", 7);
    box.put("iloscKilometrowPrzypomnienia", 1000);
  }
  var box1 = await Hive.openBox("szczegoly_auta");

  if (box1.isEmpty) {
    // Jeśli pudełko jest puste, utwórz je z odpowiednią ilością indeksów.
    box1.add(""); // Dodaj pierwszy element (indeks 0).
    box1.add(""); // Dodaj drugi element (indeks 1).
    box1.add(""); // Dodaj trzeci element (indeks 2).
    box1.add(""); // Dodaj czwarty element (indeks 3).
  } else {
    // Jeśli pudełko nie jest puste, sprawdź każdy indeks osobno.
    if (box1.length <= 0 || box1.getAt(0) == null) {
      box1.add(""); // Dodaj pierwszy element, jeśli nie istnieje.
    }
    if (box1.length <= 1 || box1.getAt(1) == null) {
      box1.add(""); // Dodaj drugi element, jeśli nie istnieje.
    }
    if (box1.length <= 2 || box1.getAt(2) == null) {
      box1.add(""); // Dodaj trzeci element, jeśli nie istnieje.
    }
    if (box1.length <= 3 || box1.getAt(3) == null) {
      box1.add(""); // Dodaj czwarty element, jeśli nie istnieje.
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AutoLog",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('pl'),
      ],
      locale: const Locale('pl'),
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
            background: const Color(0xffe4e1ec),
            //background: ColorScheme.fromSwatch().background,
          ),
          useMaterial3: true),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.dark),
          useMaterial3: true),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Column(
        children: [
          Expanded(
            child: ShowCaseWidget(
              builder: Builder(
                builder: (context) => const EkranGlowny(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
