import 'dart:convert';
import 'dart:math';

String generateToken({int length = 32}) {
  final Random random = Random.secure();
  final List<int> values = List<int>.generate(length, (i) => random.nextInt(256));

  return base64Url.encode(values);
}
