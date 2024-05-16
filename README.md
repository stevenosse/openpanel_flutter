# Openpanel Flutter SDK

Non official Flutter SDK for [Openpanel](https://openpanel.dev), the open source
alternative to Mixpanel

## Getting started

Install this package from [pub.dev](https://pub.dev)

```bash
$ flutter pub add openpanel_flutter
```

## Usage

Import the package:

```dart
import 'package:openpanel_flutter/openpanel_flutter.dart';
```

Then you need to initialize Openpanel before using it:

```dart
import 'package:openpanel_flutter/openpanel_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Openpanel.instance.initialize(
    options: OpenpanelOptions(
        clientId: <YOUR_CLIENT_ID>,
        clientSecret: <YOUR_CLIENT_SECRET>,
    )
  );

  runApp(MyApp());
}
```

Add the `OpenpanelRouteObserver`if you want to track navigation

## Track event

To track an event, use:

```dart
Openpanel.instance.event('event_name', properties: {
    ...
})
```

## Additional information
- Openpanel: [Github Repo](https://github.com/Openpanel-dev/openpanel)
- Maintainer: [Steve NOSSE](https://x.com/nossesteve)