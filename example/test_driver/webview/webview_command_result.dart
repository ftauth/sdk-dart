import 'package:flutter_driver/flutter_driver.dart';

class WebViewCommandResult extends Result {
  final bool success;
  final String? error;

  const WebViewCommandResult(this.success, [this.error]);

  WebViewCommandResult.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        error = json['error'];

  factory WebViewCommandResult.success() => WebViewCommandResult(true);
  factory WebViewCommandResult.error(String error) =>
      WebViewCommandResult(false, error);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'error': error,
    };
  }
}
