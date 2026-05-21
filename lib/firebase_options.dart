// File generated manually from google-services.json + GoogleService-Info.plist
// Project: bio-vms-bi26

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCs8miAa-olicUPcbVYol3ymz6-wqaDTOg',
    appId: '1:321260026726:android:07c1d09ed46365dfb766a7',
    messagingSenderId: '321260026726',
    projectId: 'bio-vms-bi26',
    storageBucket: 'bio-vms-bi26.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDeHzNjH4UxFgzQ_xOhLJ_bFDqNBhSWzF4',
    appId: '1:321260026726:ios:789d38832a9c5835b766a7',
    messagingSenderId: '321260026726',
    projectId: 'bio-vms-bi26',
    storageBucket: 'bio-vms-bi26.firebasestorage.app',
    iosBundleId: 'com.bioexperience.vmsapp',
  );
}
