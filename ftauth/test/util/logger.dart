import 'package:ftauth/ftauth.dart';

class NoOutputLogger implements LoggerInterface {
  const NoOutputLogger();

  @override
  void debug(String log) {}

  @override
  void error(String log) {}

  @override
  void info(String log) {}

  @override
  void warn(String log) {}
}
