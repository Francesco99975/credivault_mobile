import 'package:flutter/material.dart';
import '../widgets/crypto.dart';
import '../widgets/main_drawer.dart';

class FastCryptoScreen extends StatelessWidget {
  static const ROUTE_NAME = '/fast-crypto';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fast Crypto (BME)"),
      ),
      drawer: MainDrawer(),
      body: SafeArea(child: Crypto()),
    );
  }
}
