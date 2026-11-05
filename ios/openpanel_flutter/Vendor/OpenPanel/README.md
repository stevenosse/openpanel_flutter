# Vendored OpenPanel Swift SDK

Source: https://github.com/Openpanel-dev/swift-sdk
Revision: `d8181ebb986acce3e3bb177a93cc484241ba0414` (1.0.0)

Included as a SwiftPM target, with the upstream license.

Local patch: unwrap `IdentifyPayload.properties` before merging them with global
properties. Upstream otherwise wraps `AnyCodable` values a second time, and
identification requests fail JSON encoding whenever global properties exist.

The Flutter bridge separately normalizes NSNumber booleans before passing them
to the SDK's AnyCodable encoder. Run `example/integration_test/openpanel_test.dart`
on iOS after any SDK update to verify the actual requests.
