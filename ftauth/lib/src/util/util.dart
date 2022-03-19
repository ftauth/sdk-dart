import 'dart:convert';

String prettyPrintJson(Object? o) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(o);
}
