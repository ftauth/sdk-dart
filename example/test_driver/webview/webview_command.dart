import 'package:flutter_driver/flutter_driver.dart';

class WebViewCommand extends Command {
  final String username;
  final String password;

  WebViewCommand(
    this.username,
    this.password,
  ) : super();

  WebViewCommand.deserialize(Map<String, String> json)
      : username = json['username']!,
        password = json['password']!;

  @override
  Map<String, String> serialize() {
    return super.serialize()
      ..addAll({
        'username': username,
        'password': password,
      });
  }

  @override
  String get kind => 'WebViewCommand';
}
