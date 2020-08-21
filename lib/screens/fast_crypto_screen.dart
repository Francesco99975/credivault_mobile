import 'package:credivault_mobile/providers/rsa_provider.dart';
import 'package:credivault_mobile/widgets/crypto.dart';
import 'package:credivault_mobile/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FastCryptoScreen extends StatelessWidget {
  // static const ROUTE_NAME = '/fast-crypto';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fast Crypto"),
      ),
      drawer: MainDrawer(),
      body: SafeArea(
          child: FutureBuilder(
              future:
                  Provider.of<RSAProvider>(context, listen: false).getKeyPair(),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : Crypto())),
    );
  }
}
