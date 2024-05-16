import 'package:flutter/widgets.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';

class OpenpanelRouteObserver extends RouteObserver with WidgetsBindingObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    Openpanel.instance.event(name: 'screen_view', properties: {
      '__path': route.settings.name,
    });

    super.didPush(route, previousRoute);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.getFullName() != null) {
      Openpanel.instance.event(name: state.getFullName()!);
    }

    super.didChangeAppLifecycleState(state);
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
