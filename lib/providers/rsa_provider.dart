import 'package:flutter/foundation.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart' as rsa;
import 'package:pointycastle/pointycastle.dart' as crypto;

class RSAProvider with ChangeNotifier {
  crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey> keyPair;

  Future<void> getKeyPair() async {
    var helper = rsa.RsaKeyHelper();
    keyPair = await helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  String encrypt(String txt) {
    return rsa.encrypt(txt, keyPair.publicKey);
  }

  String decrypt(String encryptedTxt) {
    return rsa.decrypt(encryptedTxt, keyPair.privateKey);
  }
}
