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

  Future<bool> _authenticateIsAvailable() async {
    final isAvailable = await localAuth.canCheckBiometrics;
    final isDeviceSupported = await localAuth.isDeviceSupported();
    print(isAvailable);
    print(isDeviceSupported);
    return isAvailable && isDeviceSupported;
  }

  bool get canUseBiometrics {
    return _biomtericsOn;
  }

  Future<bool> fingerprintAuth() async {
    try {
      if (await _authenticateIsAvailable()) {
        return await localAuth.authenticate(
            localizedReason: "Unlock your credentials",
            useErrorDialogs: true,
            biometricOnly: true);
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void cancelAuthentication() {
    localAuth.stopAuthentication();
  }
}
