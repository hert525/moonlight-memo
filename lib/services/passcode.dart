import 'dart:convert';

String encodePasscode(String passcode) {
  final bytes = utf8.encode(passcode);
  final mixed = List<int>.generate(bytes.length, (index) => bytes[index] ^ 73);
  return base64Encode(mixed);
}

String? decodePasscode(String? encoded) {
  if (encoded == null || encoded.isEmpty) return null;
  try {
    final decoded = base64Decode(encoded);
    final original = List<int>.generate(
      decoded.length,
      (index) => decoded[index] ^ 73,
    );
    return utf8.decode(original);
  } catch (_) {
    return encoded;
  }
}
