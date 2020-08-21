import 'package:credivault_mobile/providers/biometrics_provider.dart';
import 'package:credivault_mobile/providers/rsa_provider.dart';
import 'package:credivault_mobile/providers/settings_provider.dart';
import 'package:credivault_mobile/screens/loading_screen.dart';
import 'package:credivault_mobile/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:credivault_mobile/providers/credentials.dart';
import 'package:credivault_mobile/screens/add_credential_screen.dart';
import 'package:credivault_mobile/screens/credentials_database_screen.dart';
import 'package:credivault_mobile/screens/fast_crypto_screen.dart';

void main() {
  runApp(CredivaultApp());
}

class CredivaultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Settings(),
        ),
        ChangeNotifierProvider(
          create: (_) => Biometrics(),
        ),
        ChangeNotifierProvider(
          create: (_) => RSAProvider(),
        ),
        ChangeNotifierProvider(create: (_) => Credentials()),
      ],
      builder: (_, __) => MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.teal[700],
            accentColor: Colors.indigo[900],
            brightness: Brightness.dark),
        home: CredentialsDatabaseScreen(),
        title: "Credivault",
        routes: {
          FastCryptoScreen.ROUTE_NAME: (_) => FastCryptoScreen(),
          AddCredentialScreen.ROUTE_NAME: (_) => AddCredentialScreen(),
          LoadingScreen.ROUTE_NAME: (_) => LoadingScreen(),
          SettingsScreen.ROUTE_NAME: (_) => SettingsScreen()
        },
      ),
    );
  }
}
