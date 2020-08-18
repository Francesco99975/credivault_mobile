import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class Biometrics with ChangeNotifier {
  final localAuth = LocalAuthentication();
  bool _biomtericsOn = false;
  List<BiometricType> _availableBiometrics = [];

  Future<void> loadBiometrics() async {
    _biomtericsOn = await localAuth.canCheckBiometrics;

    if (!_biomtericsOn) return;

    _availableBiometrics = await localAuth.getAvailableBiometrics();

    if (!_availableBiometrics.contains(BiometricType.fingerprint)) {
      _biomtericsOn = false;
      return;
    }
  }

  bool get canUseBiometrics {
    return _biomtericsOn;
  }

  Future<bool> fingerprintAuth() async {
    return await localAuth.authenticateWithBiometrics(
        localizedReason: "Unlock your credentials", useErrorDialogs: true);
  }

  void cancelAuthentication() {
    localAuth.stopAuthentication();
  }
}
