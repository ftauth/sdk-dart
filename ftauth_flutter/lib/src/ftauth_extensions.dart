import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

extension FTAuthX on FTAuth {
  void initFlutter() {
    authorizer = FlutterAuthorizer();
  }
}
