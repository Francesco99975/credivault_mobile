import 'package:credivault_mobile/providers/subscription.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
import './providers/biometrics_provider.dart';
import './providers/rsa_provider.dart';
import './providers/settings_provider.dart';
import './screens/loading_screen.dart';
import './screens/settings_screen.dart';
import './providers/credentials.dart';
import './screens/add_credential_screen.dart';
import './screens/credentials_database_screen.dart';
import './screens/fast_crypto_screen.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(CredivaultApp());
}

class CredivaultApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Subscription(),
        ),
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
            fontFamily: "Jura",
            textTheme: TextTheme(
                headline1: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.white)),
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: Colors.indigo[900])),
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
