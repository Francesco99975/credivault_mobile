import 'package:flutter/material.dart';
import '../screens/fast_crypto_screen.dart';

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
            title: Text(
              "Credivault",
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  .copyWith(color: Colors.amber),
            ),
            automaticallyImplyLeading: false,
          ),
          _buildRoute(context, "Credentials", Icons.storage, "/"),
          _buildRoute(context, "Fast Crypto", Icons.enhanced_encryption,
              FastCryptoScreen.ROUTE_NAME),
        ],
      ),
    );
  }
}
