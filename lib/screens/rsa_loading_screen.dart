import 'package:flutter/material.dart';

class RSALoadingScreen extends StatelessWidget {
  static const ROUTE = "/rsa-loading";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              LinearProgressIndicator(
                backgroundColor: Colors.amber,
              ),
              SizedBox(
                height: 10,
              ),
              const Text("Generating Secure RSA Keys...",
                  textAlign: TextAlign.center),
              SizedBox(
                height: 10,
              ),
              const Text("This may take few minutes...",
                  textAlign: TextAlign.center)
            ],
          ),
        ),
      ),
    );
  }
}
