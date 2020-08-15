import 'package:credivault_mobile/providers/credential.dart';
import 'package:flutter/foundation.dart';
import '../db/database_provider.dart';

class Credentials with ChangeNotifier {
  List<Credential> _items = [];

  List<Credential> get items {
    return [..._items];
  }

  var _credVisible = true;

  Future<void> loadCredentials() async {
    _items = await DatabseProvider.db.getCredentials();
    notifyListeners();
  }

  Future<void> addCredential(Credential crd) async {
    await DatabseProvider.db.insertCredential(crd);
    _items.add(crd);
    notifyListeners();
  }

  Future<void> updateCredential(String id, Credential crd) async {
    await DatabseProvider.db.updateCredential(id, crd);
    final index = _items.indexWhere((crd) => crd.id == id);
    _items.replaceRange(index, index + 1, [crd]);
    notifyListeners();
  }

  Future<void> deleteCredential(String id) async {
    await DatabseProvider.db.deleteCredential(id);
    _items.removeWhere((crd) => crd.id == id);
    notifyListeners();
  }

  Credential findById(String id) {
    return _items.singleWhere((itm) => itm.id == id);
  }

  int size() {
    return _items.length;
  }

  void toggleVisible() {
    _credVisible = !_credVisible;
    notifyListeners();
  }

  bool visible() {
    return _credVisible;
  }

  void rearrange(oldIndex, newIndex) {
    Credential tmp = _items[oldIndex];
    _items.removeAt(oldIndex);
    _items.insert(newIndex, tmp);

    if (newIndex > oldIndex) {
      for (var i = newIndex; i >= 0; --i) {
        _items[i].priority = i;
      }
    } else if (newIndex < oldIndex) {
      for (var i = newIndex; i < _items.length; ++i) {
        _items[i].priority = i;
      }
    }

    _items.forEach(
        (itm) async => await DatabseProvider.db.updateCredential(itm.id, itm));
    notifyListeners();
  }
}
