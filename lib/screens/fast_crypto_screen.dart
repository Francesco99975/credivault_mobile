import 'package:credivault_mobile/widgets/crypto.dart';
import 'package:credivault_mobile/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

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
