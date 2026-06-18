/// Client-editable runtime configuration.
///
/// Replace the placeholder values below with your own before shipping.
class AppConfig {
  const AppConfig._();

  /// Where the "Support the app" button sends users. Replace with your own
  /// Ko-fi / Buy Me a Coffee / PayPal.me / Patreon link.
  static const String donationUrl = 'https://ko-fi.com/';

  /// Optional OAuth **Web client ID** from your Firebase project (Authentication
  /// → Sign-in method → Google). Some Android setups need it for Google
  /// sign-in. Leave empty to let the platform auto-detect from
  /// google-services.json. See SETUP.md.
  static const String googleServerClientId = '';
}
