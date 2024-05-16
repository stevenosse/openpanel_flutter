import 'package:flutter/widgets.dart';
import 'package:openpanel_flutter/openpanel_flutter.dart';
import 'package:openpanel_flutter/src/models/typedefs.dart';

bool defaultRouteFilter(Route<dynamic>? route) => route is PageRoute;

class OpenpanelObserver extends RouteObserver with WidgetsBindingObserver {
  final RouteFilter routeFilter;

  OpenpanelObserver({this.routeFilter = defaultRouteFilter});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (routeFilter(route)) {
      _trackScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && routeFilter(newRoute)) {
      _trackScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null && routeFilter(previousRoute) && routeFilter(route)) {
      _trackScreenView(previousRoute);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.getFullName() != null) {
      Openpanel.instance.event(name: state.getFullName()!);
    }

    super.didChangeAppLifecycleState(state);
  }

  void _trackScreenView(Route<dynamic> route) {
    if (route.settings.name == null) {
      return;
    }

    Openpanel.instance.event(name: 'screen_view', properties: {
      '__path': route.settings.name,
    });
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
