import 'package:flutter/foundation.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart' as rsa;
import 'package:pointycastle/pointycastle.dart' as crypto;
import 'package:shared_preferences/shared_preferences.dart';

class RSAProvider with ChangeNotifier {
  crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey> keyPair;

  Future<void> getKeyPair() async {
    if (keyPair == null) {
      final prefs = await SharedPreferences.getInstance();
      var helper = rsa.RsaKeyHelper();
      final pubKey = prefs.getString("rsa_public_key") ?? null;
      final prvKey = prefs.getString("rsa_private_key") ?? null;
      if (pubKey != null && prvKey != null) {
        print("Loading KeyPairs");
        keyPair = crypto.AsymmetricKeyPair(helper.parsePublicKeyFromPem(pubKey),
            helper.parsePrivateKeyFromPem(prvKey));
      } else {
        print("Genererating new Key pairs");
        keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());
        prefs.setString("rsa_public_key",
            helper.encodePublicKeyToPemPKCS1(keyPair.publicKey));
        prefs.setString("rsa_private_key",
            helper.encodePrivateKeyToPemPKCS1(keyPair.privateKey));
      }
    }
  }

  String encrypt(String txt) {
    return rsa.encrypt(txt, keyPair.publicKey);
  }

  String decrypt(String encryptedTxt) {
    return rsa.decrypt(encryptedTxt, keyPair.privateKey);
  }
}
