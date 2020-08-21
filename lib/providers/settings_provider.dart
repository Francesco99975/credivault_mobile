import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../db/database_provider.dart';

class Settings with ChangeNotifier {
  static const _url = "https://bme-encdec-server.herokuapp.com";
  String _encryptedMasterPassword;
  bool _authMode;

  Future<void> loadSettings() async {
    _authMode = await DatabseProvider.db.getAuthMode();
    _encryptedMasterPassword =
        await DatabseProvider.db.getEncryptedMasterPassword();
  }

  Future<String> get masterPassword async {
    final res = await http.post("$_url/decrypt",
        body: json.encode({'data': _encryptedMasterPassword}),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    final extractedData = json.decode(res.body);

    return extractedData['data'];
  }

  Future<void> setMasterPassword(String password) async {
    final res = await http.post("$_url/encrypt",
        body: json.encode({'data': password}),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    final extractedData = json.decode(res.body);
    _encryptedMasterPassword = extractedData['data'];
    await DatabseProvider.db
        .setEncryptedMasterPassword(_encryptedMasterPassword);
    notifyListeners();
  }

  Future<void> toggleAuthMode() async {
    await DatabseProvider.db.setAuthMode(!_authMode);
    _authMode = !_authMode;
    notifyListeners();
  }

  bool get authMode {
    return _authMode;
  }

  bool unset() {
    return _encryptedMasterPassword.trim().isNotEmpty;
  }
}
