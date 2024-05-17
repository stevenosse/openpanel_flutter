import 'package:flutter/widgets.dart';
import 'package:openpanel_flutter/src/open_panel.dart';
import 'package:referrer/referrer.dart' as r;

class LifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.getFullName() != null) {
      Openpanel.instance.event(name: state.getFullName()!);
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Future<bool> didPushRouteInformation(
      RouteInformation routeInformation) async {
    final referrerInfo = await r.Referrer().getReferrer();
    if (referrerInfo?.referrer != null) {
      Openpanel.instance.setGlobalProperties({
        '__referrer': referrerInfo!.referrer,
      });
    }

    return super.didPushRouteInformation(routeInformation);
  }
}

extension on AppLifecycleState {
  String? getFullName() => switch (this) {
        AppLifecycleState.paused ||
        AppLifecycleState.inactive ||
        AppLifecycleState.hidden =>
          'Application backgrounded',
        AppLifecycleState.resumed => 'Application foregrounded',
        _ => null,
      };
}
