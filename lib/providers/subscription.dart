// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';

// class Subscription with ChangeNotifier {
//   final List<String> _kProductIds = <String>['upgrade', 'subscription'];
//   StreamSubscription<List<PurchaseDetails>> _subscription;

//   Future<bool> available() async {
//     await InAppPurchaseConnection.instance.isAvailable();
//   }

//   void _handlePurchaseUpdates(PurchaseDetails purchases) {}

//   void loadSubscription() {
//     final Stream purchaseUpdates =
//         InAppPurchaseConnection.instance.purchaseUpdatedStream;
//     _subscription = purchaseUpdates.listen((purchases) {
//       _handlePurchaseUpdates(purchases);
//     }, onDone: () => _subscription.cancel());
//   }
// }
