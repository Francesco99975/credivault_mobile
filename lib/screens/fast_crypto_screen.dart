import 'package:flutter/material.dart';
import '../widgets/crypto.dart';
import '../widgets/main_drawer.dart';

class FastCryptoScreen extends StatelessWidget {
  static const ROUTE_NAME = '/fast-crypto';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            "Fast Crypto (BME)",
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
      drawer: MainDrawer(),
      body: SafeArea(child: Crypto()),
    );
  }
}
