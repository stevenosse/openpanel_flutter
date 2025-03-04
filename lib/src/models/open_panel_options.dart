/// Openpanel options
///
/// This is used to configure Openpanel
class OpenpanelOptions {
  /// This is the base url of the Openpanel API.
  /// You may want to change this if you are using a self-hosted version of Openpanel.
  ///
  /// Default value is: https://api.openpanel.dev
  final String? url;

  /// Your Openpanel client id.
  final String clientId;

  /// Your Openpanel client secret.
  final String? clientSecret;

  /// Enable verbose logging
  final bool verbose;

  OpenpanelOptions({
    this.url,
    required this.clientId,
    this.clientSecret,
    this.verbose = false,
  });
}
