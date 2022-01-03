import 'package:ftauth/ftauth.dart';

export 'authorizer_base.dart';
export 'authorizer_stub.dart'
    if (dart.library.io) 'authorizer_io.dart'
    if (dart.library.html) 'authorizer_html.dart';

abstract class AuthorizerInterface implements SSLPinningInterface {
  /// Initializes the SDK. **Must** be called before performing any activities.
  Future<void> init();

  /// Initiates the authorization code flow.
  Future<String> authorize({
    String? language,
    String? countryCode,
  });

  /// Launches the given URL.
  Future<void> launchUrl(String url);

  /// Performs the second part of the authorization code flow, exhanging the
  /// parameters retrieved via the WebView with the OAuth server for an access
  /// and refresh token.
  Future<Client> exchange(Map<String, String> parameters);

  /// Performs the full two-step OAuth process.
  ///
  /// Some platforms may need to split this between [authorize] and [exchange].
  Future<void> login({
    String? language,
    String? countryCode,
  });

  /// Logs out the current user.
  Future<void> logout();

  /// The current authorization state.
  AuthState get currentState;

  /// Returns the stream of authorization states.
  ///
  /// Possible [AuthState] values include:
  /// * [AuthLoading]: Information is refreshing or being retrieved.
  /// * [AuthSignedIn]: User is logged in with valid credentials.
  /// * [AuthSignedOut]: User is logged out or has expired credentials.
  /// * [AuthFailure]: An error has occurred during authentication or during an HTTP request.
  Stream<AuthState> get authStates;

  /// Pull the latest auth state from the keychain. If, for example, an app extension
  /// refreshed it, we may not have the latest.
  Future<void> refreshAuthState();
}
