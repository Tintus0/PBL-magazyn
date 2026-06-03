import 'dart:convert';
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  const salt = 'smart_magazyn_offline_v1';
  return sha256.convert(utf8.encode('$salt:$password')).toString();
}
