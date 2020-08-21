import 'package:credivault_mobile/screens/fast_crypto_screen.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  Widget _buildRoute(
      BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.of(context).pushReplacementNamed(route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: const Text("Credivault"),
            automaticallyImplyLeading: false,
          ),
          _buildRoute(context, "Credentials Database", Icons.storage, "/"),
          _buildRoute(context, "Fast Crypto", Icons.enhanced_encryption,
              FastCryptoScreen.ROUTE_NAME),
        ],
      ),
    );
  }
}
