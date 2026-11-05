/// OpenPanel options used to configure the SDK.
///
/// ```dart
/// Openpanel.instance.initialize(
///   options: OpenpanelOptions(
///     clientId: '<YOUR_CLIENT_ID>',
///     clientSecret: '<YOUR_CLIENT_SECRET>',
///   ),
/// );
/// ```
class OpenpanelOptions {
  /// The base URL of the OpenPanel API.
  ///
  /// You may want to change this if you are using a self-hosted instance of
  /// OpenPanel.
  ///
  /// Defaults to `https://api.openpanel.dev`.
  final String? apiUrl;

  /// Your OpenPanel client id.
  final String clientId;

  /// Your OpenPanel client secret.
  ///
  /// Only required for server-side events.
  final String? clientSecret;

  /// Enable verbose logging.
  final bool verbose;

  /// Percentage of sessions that will be sampled for tracing (0.0 - 1.0).
  ///
  /// Events are dropped when the session is not sampled. This is a
  /// Flutter-specific feature and is applied before events reach the native
  /// SDKs.
  final double tracingSampleRate;

  /// Disable all event collection.
  ///
  /// This is the initial value of `Openpanel.setCollectionEnabled`. It can be
  /// changed at runtime.
  final bool disabled;

  /// Automatically track app lifecycle events (`app_opened` and
  /// `app_closed`).
  ///
  /// This is handled by the official OpenPanel Kotlin and Swift SDKs.
  final bool automaticTracking;

  /// Delay sending events until a profile has been identified.
  ///
  /// Call `Openpanel.ready` to flush queued events without identifying a
  /// profile.
  final bool waitForProfile;

  OpenpanelOptions({
    String? url,
    String? apiUrl,
    required this.clientId,
    this.clientSecret,
    this.verbose = false,
    this.tracingSampleRate = 1.0,
    this.disabled = false,
    this.automaticTracking = false,
    this.waitForProfile = false,
  }) : apiUrl = apiUrl ?? url;

  /// Deprecated alias for [apiUrl].
  @Deprecated('Use apiUrl instead.')
  String? get url => apiUrl;

  /// Creates a copy of these options with the given fields replaced.
  OpenpanelOptions copyWith({
    String? apiUrl,
    String? clientId,
    String? clientSecret,
    bool? verbose,
    double? tracingSampleRate,
    bool? disabled,
    bool? automaticTracking,
    bool? waitForProfile,
  }) {
    return OpenpanelOptions(
      apiUrl: apiUrl ?? this.apiUrl,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      verbose: verbose ?? this.verbose,
      tracingSampleRate: tracingSampleRate ?? this.tracingSampleRate,
      disabled: disabled ?? this.disabled,
      automaticTracking: automaticTracking ?? this.automaticTracking,
      waitForProfile: waitForProfile ?? this.waitForProfile,
    );
  }
}
