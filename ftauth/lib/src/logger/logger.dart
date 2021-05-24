abstract class LoggerInterface {
  void debug(String log);
  void info(String log);
  void warn(String log);
  void error(String log);
}

/// A logger which prints all output to the console.
class StdoutLogger implements LoggerInterface {
  const StdoutLogger();

  @override
  void debug(String log) {
    print('${DateTime.now()} [DEBUG]: $log');
  }

  @override
  void error(String log) {
    print('${DateTime.now()} [ERROR]: $log');
  }

  @override
  void info(String log) {
    print('${DateTime.now()} [INFO]: $log');
  }

  @override
  void warn(String log) {
    print('${DateTime.now()} [WARN]: $log');
  }
}
