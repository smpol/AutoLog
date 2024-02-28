import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import '../api.dart';

class ReklamaBaner extends StatefulWidget {
  const ReklamaBaner({super.key});

  @override
  State<ReklamaBaner> createState() => _ReklamaBanerState();
}

class _ReklamaBanerState extends State<ReklamaBaner> {
  BannerAd? _bannerAd;

  final String _adUnitId = ADMOB_KEY;
   //final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        _loadAd();
      }
    }
  }

  void _loadAd() async {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        //onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        //onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        //onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    //create bottomNavigationBar
    return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        width: double.infinity,
        // height: 50,
        child:
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     "Reklama",
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 20.0),
            //   ),
            // ),
            Column(
          children: [
            if (kIsWeb)
              const SizedBox(
                height: 0,
              ),
            if (!kIsWeb)
              if (Platform.isAndroid || Platform.isIOS)
                if (_bannerAd == null)
                  const SizedBox(
                    height: 0,
                  )
                else
                  SizedBox(
                    height: 50,
                    child: AdWidget(
                      ad: _bannerAd!,
                    ),
                  )
          ],
        ));
  }
}
