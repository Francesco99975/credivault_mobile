import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  static const ROUTE_NAME = '/loading';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
