import 'dart:convert';
import 'dart:io';

import 'package:ftauth_jwt/ftauth_jwt.dart';

final outFile = File('test/data/data.g.dart');
final pubFile = File(Directory.systemTemp.path + '/pub.json')..createSync();
final privFile = File(Directory.systemTemp.path + '/priv.json')..createSync();
final keysetFile = File(Directory.systemTemp.path + '/keyset.json');
final jwtFile = File(Directory.systemTemp.path + '/jwt.json')..createSync();

final keys = <_Tuple>[];

class _Tuple {
  final Algorithm alg;
  final String publicKey;
  final String privateKey;

  _Tuple(this.alg, this.publicKey, this.privateKey);
}

Future<void> main() async {
  final testStep = await Process.run('which', ['step']);
  if (testStep.exitCode != 0) {
    exitCode = 1;
    stderr.writeln(
        'This script relies on the step tool (https://github.com/smallstep/cli).');
  }

  if (outFile.existsSync()) {
    outFile.deleteSync();
    outFile.createSync();
  }

  outFile.writeAsStringSync('''
/// This is a generated file. DO NOT EDIT.
/// Run `script/generate_data.dart` to regenerate this data.

import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'test_case.dart';

  ''');

  // Generate keys
  for (final alg in Algorithm.values.where((alg) => alg.isValid)) {
    await generateKey(alg);
  }

  // Generate JWTs
  for (final tuple in keys) {
    await _generateJWT(tuple);
  }

  // Generate test cases
  await generateTestCases();

  // Generate keyset
  await generateKeySet();

  final format = await Process.run('dart', [
    'format',
    outFile.path,
  ]);
  print(format.stdout);
  exitCode = format.exitCode;
  if (exitCode != 0) {
    print('Error formatting: ${format.stderr}');
  }
}

Future<void> generateKeySet() async {
  if (keysetFile.existsSync()) {
    keysetFile.deleteSync();
    keysetFile.createSync();
  }
  for (final tuple in keys) {
    final cat = await Process.start('echo', [tuple.publicKey]);
    final step = await Process.start('step', [
      'crypto',
      'jwk',
      'keyset',
      'add',
      keysetFile.path,
    ]);
    await cat.stdout.pipe(step.stdin);
    await step.stderr.pipe(stderr);
    final code = await step.exitCode;
    if (code != 0) {
      exit(code);
    }
  }
  outFile.writeAsStringSync('''
  const keySet = \'\'\'
  ${keysetFile.readAsStringSync()}
  \'\'\';
  ''', mode: FileMode.append);
}

Future<void> generateTestCases() async {
  final sb = StringBuffer();
  sb.writeln('const testCases = <TestCase>[');
  for (final tuple in keys) {
    final alg = tuple.alg;
    sb.writeln('''
    TestCase(
      ${alg.toString()},
      ${alg.code}_private_jwk,
      ${alg.code}_public_jwk,
      ${alg.code}_jwt,
    ),
    ''');
  }
  sb.writeln('];\n');
  outFile.writeAsStringSync(sb.toString(), mode: FileMode.append);
}

Future<void> generateKey(Algorithm algorithm) async {
  switch (algorithm.keyType) {
    case KeyType.ellipticCurve:
      EllipticCurve curve;
      switch (algorithm) {
        case Algorithm.ecdsaSha256:
          curve = EllipticCurve.p256;
          break;
        case Algorithm.ecdsaSha384:
          curve = EllipticCurve.p384;
          break;
        case Algorithm.ecdsaSha512:
          curve = EllipticCurve.p521;
          break;
        default:
          throw '';
      }
      return _generateKeyPair(
        algorithm,
        curve: curve,
      );
    default:
      return _generateKeyPair(algorithm);
  }
}

Future<void> _generateKeyPair(
  Algorithm algorithm, {
  EllipticCurve? curve,
}) async {
  final out = await Process.run('step', [
    'crypto',
    'jwk',
    'create',
    pubFile.path,
    privFile.path,
    '--kty=${algorithm.keyType!.code}',
    if (curve != null) '--crv=${curve.code}',
    '--alg=${algorithm.code}',
    '--use=sig',
    '--no-password',
    '--insecure',
    '--force',
  ]);
  if (out.exitCode != 0) {
    stderr.writeln(out.stderr);
    exit(1);
  }
  final pubKey = pubFile.readAsStringSync();
  final privKey = privFile.readAsStringSync();
  outFile.writeAsStringSync('''
  const ${algorithm.code}_private_jwk = \'\'\'
  $privKey
  \'\'\';

  const ${algorithm.code}_public_jwk = \'\'\'
  $pubKey
  \'\'\';

  ''', mode: FileMode.append);
  keys.add(_Tuple(algorithm, pubKey, privKey));
}

Future<void> _generateJWT(_Tuple tuple) async {
  privFile.writeAsStringSync(tuple.privateKey);
  final expiration =
      DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch ~/
          1000;
  final echo = await Process.start('echo', ['{}']);
  final out = await Process.start('step', [
    'crypto',
    'jwt',
    'sign',
    '--key=${privFile.path}',
    '--iss=ftauth.io',
    '--aud=test',
    '--sub=test',
    '--exp=$expiration',
  ]);
  await echo.stdout.pipe(out.stdin);
  await out.stderr.pipe(stderr);
  final outExitCode = await out.exitCode;
  if (outExitCode != 0) {
    exit(1);
  }
  final jwt = await out.stdout.transform(utf8.decoder).join();
  outFile.writeAsStringSync('''
  const ${tuple.alg.code}_jwt = '${jwt.trim()}';

  ''', mode: FileMode.append);
}
