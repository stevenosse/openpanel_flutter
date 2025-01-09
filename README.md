# Openpanel Flutter SDK

[![Package on pub.dev][pubdev_badge]][pubdev_link]

Non official Flutter SDK for [Openpanel](https://openpanel.dev), the open source
alternative to Mixpanel, GA & Plausible.

## Getting started

First, you need to create an account on [Openpanel](https://openpanel.dev).

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

### Track navigation
Add the `OpenpanelObserver`if you want to track navigation

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OpenpanelObserver(
      child: MaterialApp(
        navigatorObservers: [
          OpenpanelObserver()
        ],
        ...
      ),
    );
  }
}
```

### Track event

To track an event, use:

```dart
Openpanel.instance.event('event_name', properties: {
  ...
})
```

### Global properties

You can set global properties that will be sent with every event. This is useful
if you want to set a custom user id for example.

```dart
Openpanel.instance.setGlobalProperties({
  'user_id': '123',
  ...
});
```

### Other options

#### Customize the url
You can also customize the url of the openpanel server. This is useful if you have a custom domain or use a self-hosted instance of Openpanel.

#### Enable verbose logging
```dart
Openpanel.instance.initialize(
  options: OpenpanelOptions(
    clientId: <YOUR_CLIENT_ID>,
    clientSecret: <YOUR_CLIENT_SECRET>,
    verbose: true
  )
)
```

#### Disable events collection
You can disable events collection if you don't want to send events to Openpanel.
```dart
Openpanel.instance.setCollectionEnabled(false);
```

## Data Tracking

This plugin automatically tracks the following data:
- App version
- Build number
- Platform
- Device model
- Os version
- Manufacturer

## Issues

- [GitHub Issues](https://github.com/stevenosse/openpanel_flutter/issues)
- [Openpanel Issues](https://github.com/Openpanel-dev/openpanel/issues)

## Contributing
If you wish to contribute, please send a PR to the [Github Repo](https://github.com/stevenosse/openpanel_flutter)

## Credits
- Openpanel: [Github Repo](https://github.com/Openpanel-dev/openpanel) | [Website](https://openpanel.dev) | [Documentation](https://docs.openpanel.dev) | [Author](https://x.com/CarlLindesvard)

- Maintainer: [Steve NOSSE](https://x.com/nossesteve)

[pubdev_badge]: https://img.shields.io/pub/v/openpanel_flutter
[pubdev_link]: https://pub.dev/packages/openpanel_flutter