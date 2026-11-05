import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:referrer/referrer.dart' as r;

/// Tracks the install referrer URL.
///
/// Add this observer during initialization if you want to send the referrer as
/// a global property:
///
/// ```dart
/// Openpanel.instance.initialize(
///   options: OpenpanelOptions(clientId: '<YOUR_CLIENT_ID>'),
/// );
/// ```
class ReferrerObserver with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
    try {
      final referrerInfo = await r.Referrer().getReferrer();
      final referrer = referrerInfo?.referrer?.toString();
      if (referrer != null && referrer.isNotEmpty) {
        Openpanel.instance.setGlobalProperties({'__referrer': referrer});
      }
    } on MissingPluginException {
      // The referrer plugin is not available on this platform.
    } on PlatformException {
      // The platform refused to return the referrer.
    }

    return super.didPushRouteInformation(routeInformation);
  }
}
