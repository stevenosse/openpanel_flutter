import 'package:flutter/widgets.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:referrer/referrer.dart' as r;

/// Tracks referrer url
///
/// This is used to track the referrer url
class ReferrerObserver with WidgetsBindingObserver {
  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final referrerInfo = await r.Referrer().getReferrer();
    if (referrerInfo?.referrer != null) {
      Openpanel.instance.setGlobalProperties({
        '__referrer': referrerInfo!.referrer,
      });
    }

    return super.didPushRouteInformation(routeInformation);
  }
}
