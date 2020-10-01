import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:KhadoAndSons/utils/resources/strings.dart';

const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  childDirected: true,
  nonPersonalizedAds: true,
);

BannerAd createBannerAd() {
  return BannerAd(
    adUnitId: Platform.isAndroid ? android_banner_id : ios_banner_id,
    size: AdSize.banner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("BannerAd event $event");
    },
  );
}

InterstitialAd createInterstitialAd() {
  return InterstitialAd(
    adUnitId:
        Platform.isAndroid ? android_interstitial_id : ios_interstitial_id,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      print("InterstitialAd event $event");
    },
  );
}
