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
        ChangeNotifierProvider(create: (_) => Credentials()),
        ChangeNotifierProvider(
          create: (_) => Settings(),
        )
      ],
      builder: (_, __) => MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.teal[700],
            accentColor: Colors.indigo[900],
            brightness: Brightness.dark),
        home: FastCryptoScreen(),
        title: "Credivault",
        routes: {
          CredentialsDatabaseScreen.ROUTE_NAME: (_) =>
              CredentialsDatabaseScreen(),
          AddCredentialScreen.ROUTE_NAME: (_) => AddCredentialScreen(),
          LoadingScreen.ROUTE_NAME: (_) => LoadingScreen(),
          SettingsScreen.ROUTE_NAME: (_) => SettingsScreen()
        },
      ),
    );
  }
}
