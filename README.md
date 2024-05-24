# Openpanel Flutter SDK

[![Package on pub.dev][pubdev_badge]][pubdev_link]

Non official Flutter SDK for [Openpanel](https://openpanel.dev), the open source
alternative to Mixpanel, GA & Plausible.

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

Add the `OpenpanelObserver`if you want to track navigation

## Track event

To track an event, use:

```dart
Openpanel.instance.event('event_name', properties: {
    ...
})
```

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