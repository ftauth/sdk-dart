part of 'aws_signer.dart';

/// Runs the given sign function in a [Zone] where [print] defers to [safePrint]
/// in order to prevent accidental exposure of secrets.
R _signZoned<R>(R Function() signFn) {
  return runZoned(signFn, zoneSpecification: ZoneSpecification(
    print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      safePrint(line);
    },
  ));
}
