import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import '../util/jwt.dart';
import 'mock_http_client.dart';

class _Request {
  final String clientId;
  final Uri redirectUri;
  final String state;
  final String codeChallenge;
  final String scope;
  final String authCode;

  _Request({
    required this.clientId,
    required this.redirectUri,
    required this.state,
    required this.codeChallenge,
    required this.scope,
    required this.authCode,
  });
}

const paramResponseType = 'response_type';
const paramClientID = 'client_id';
const paramScope = 'scope';
const paramState = 'state';
const paramRedirectURI = 'redirect_uri';
const paramGrantType = 'grant_type';
const paramCode = 'code';
const paramCodeChallenge = 'code_challenge';
const paramCodeChallengeMethod = 'code_challenge_method';
const paramCodeVerifier = 'code_verifier';
const paramUsername = 'username';
const paramPassword = 'password';
const paramRefreshToken = 'refresh_token';
const paramProvider = 'provider';
const paramError = 'error';
const paramErrorDescription = 'error_description';
const paramErrorURI = 'error_uri';

class MockOAuthServer {
  final Map<String, _Request> _pendingRequests = {};
  final JwtUtil _jwtUtil;

  MockOAuthServer(this._jwtUtil);

  void reset() {
    _pendingRequests.clear();
  }

  MockHttpClient get mockHttpClient => MockHttpClient(
        userInfoHandler: (_) async {
          final user = User(id: 'test');
          final json = jsonEncode(user.toJson());
          return Response(json, 200);
        },
        authorizeHandler: (request) async {
          final query = request.url.queryParameters;

          final state = query[paramState];
          if (state == null) {
            return _missingParameter(paramState, state: null);
          }
          final clientId = query[paramClientID];
          if (clientId == null) {
            return _missingParameter(paramClientID, state: state);
          }
          final redirectUrl = query[paramRedirectURI];
          if (redirectUrl == null) {
            return _missingParameter(paramRedirectURI, state: state);
          }
          final redirectUri = Uri.tryParse(redirectUrl);
          if (redirectUri == null) {
            return _missingParameter(paramRedirectURI, state: state);
          }
          final codeChallenge = query[paramCodeChallenge];
          if (codeChallenge == null) {
            return _missingParameter(paramCodeChallenge, state: state);
          }
          final scope = query[paramScope];
          if (scope == null) {
            return _missingParameter(paramScope, state: state);
          }

          final authCode = generateState();

          final session = _Request(
            clientId: clientId,
            redirectUri: redirectUri,
            codeChallenge: codeChallenge,
            state: state,
            scope: scope,
            authCode: authCode,
          );

          _pendingRequests[authCode] = session;

          return Response(
            jsonEncode({
              paramCode: authCode,
              paramState: state,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
        tokenHandler: (request) async {
          final query = request.bodyFields;

          final code = query[paramCode];
          if (code == null) {
            return _missingParameter(paramCode, state: null);
          }
          final redirectUri = query[paramRedirectURI];
          if (redirectUri == null) {
            return _missingParameter(paramRedirectURI, state: null);
          }
          final codeVerifier = query[paramCodeVerifier];
          if (codeVerifier == null) {
            return _missingParameter(paramCodeVerifier, state: null);
          }

          final session = _pendingRequests[code];
          if (session == null) {
            return _invalidRequest();
          }
          if (session.authCode != code) {
            return _invalidRequest();
          }
          if (session.redirectUri != Uri.tryParse(redirectUri)) {
            return _invalidRequest();
          }

          final jwt = await _jwtUtil.createJWTToken(
            expiration: DateTime.now().add(const Duration(minutes: 5)),
          );
          final refreshToken = Uuid().v4();
          final response = <String, dynamic>{
            'token_type': 'bearer',
            'access_token': jwt,
            'refresh_token': refreshToken,
            'expires_in': 300,
            'scope': session.scope,
          };

          return Response(
            jsonEncode(response),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

  Response _missingParameter(String parameterName, {required String? state}) {
    return Response(
      jsonEncode({
        paramState: state,
        paramError: 'Missing or invalid parameter',
        paramErrorDescription: parameterName,
      }),
      400,
      headers: {'content-type': 'application/json'},
    );
  }

  Response _invalidRequest() {
    return Response(
      jsonEncode({
        paramError: 'Invalid request',
      }),
      400,
      headers: {'content-type': 'application/json'},
    );
  }
}
