import 'package:http/http.dart';
import 'package:http/testing.dart';

typedef MockHttpHandler = Future<Response> Function(Request);

class MockHttpClient extends MockClient {
  final MockHttpHandler? userInfoHandler;
  final MockHttpHandler? tokenHandler;
  final MockHttpHandler? authorizeHandler;

  MockHttpClient({
    this.userInfoHandler,
    this.tokenHandler,
    this.authorizeHandler,
  }) : super(_createHandler(
          userInfoHandler: userInfoHandler,
          tokenHandler: tokenHandler,
          authorizeHandler: authorizeHandler,
        ));

  MockHttpClient copyWith({
    MockHttpHandler? userInfoHandler,
    MockHttpHandler? tokenHandler,
    MockHttpHandler? authorizeHandler,
  }) {
    return MockHttpClient(
      userInfoHandler: userInfoHandler ?? this.userInfoHandler,
      tokenHandler: tokenHandler ?? this.tokenHandler,
      authorizeHandler: authorizeHandler ?? this.authorizeHandler,
    );
  }

  static MockClientHandler _createHandler({
    MockHttpHandler? userInfoHandler,
    MockHttpHandler? tokenHandler,
    MockHttpHandler? authorizeHandler,
  }) {
    return (Request request) async {
      switch (request.url.path) {
        case '/authorize':
          if (authorizeHandler != null) {
            return authorizeHandler(request);
          }
          break;
        case '/token':
          if (tokenHandler != null) {
            return tokenHandler(request);
          }
          break;
        case '/userinfo':
          if (userInfoHandler != null) {
            return userInfoHandler(request);
          }
          break;
      }
      return Response('Not Found', 404);
    };
  }
}
