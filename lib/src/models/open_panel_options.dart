class OpenpanelOptions {
  final String? url;
  final String clientId;
  final String? clientSecret;
  final bool verbose;

  OpenpanelOptions({
    this.url,
    required this.clientId,
    this.clientSecret,
    this.verbose = false,
  });
}
