import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class Subscription with ChangeNotifier {
  final List<String> _kProductIds = <String>[
    'dev.francescobarranca.credivault_mobile'
  ];
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> products;

  bool isSubscribed = false;
  bool isPending = true;
  bool available = false;

  bool _verifyPurchase(PurchaseDetails purchase) {
    return purchase != null && purchase.status == PurchaseStatus.purchased;
  }

  void _deliverPurchase(PurchaseDetails purchase) {
    if (purchase.productID == _kProductIds[0]) {
      isSubscribed = true;
      notifyListeners();
    }
  }

  Future<void> buySubscription() async {
    PurchaseParam purchaseParam =
        PurchaseParam(productDetails: products[0], applicationUserName: null);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList) async {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isPending = true;
      } else {
        isPending = false;
        if (purchaseDetails.status == PurchaseStatus.error) {
          print(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverPurchase(purchaseDetails);
          } else {
            isSubscribed = false;
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> loadSubscription() async {
    available = await InAppPurchase.instance.isAvailable();
    if (available) {
      final Stream purchaseUpdates = InAppPurchase.instance.purchaseStream;
      _subscription = purchaseUpdates.listen((purchases) {
        _handlePurchaseUpdates(purchases);
      }, onDone: () => _subscription.cancel());

      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails(_kProductIds.toSet());

      if (response.notFoundIDs.isNotEmpty) {
        print("Product not found");
        available = false;
        notifyListeners();
      }

      products = response.productDetails;
      // print(products);
      // print(products[0].description);

      // final QueryPurchaseDetailsResponse responsePast =
      //     await InAppPurchase.instance.queryPastPurchases();
      // if (responsePast.error != null) {
      //   available = false;
      //   print("Past Purchase error");
      //   notifyListeners();
      // }
      // for (PurchaseDetails purchase in responsePast.pastPurchases) {
      //   if (_verifyPurchase(purchase)) {
      //     _deliverPurchase(purchase);
      //     if (Platform.isIOS) {
      //       InAppPurchase.instance.completePurchase(purchase);
      //     }
      //   }
      // }
    }
  }
}
