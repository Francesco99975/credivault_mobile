import 'package:credivault_mobile/providers/credentials.dart';
import 'package:credivault_mobile/screens/add_credential_screen.dart';
import 'package:credivault_mobile/widgets/credential_item.dart';
import 'package:credivault_mobile/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CredentialsDatabaseScreen extends StatelessWidget {
  static const ROUTE_NAME = '/credentials-database';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Credentials"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).pushNamed(
                AddCredentialScreen.ROUTE_NAME,
                arguments: {'editMode': false}),
          ),
          IconButton(
            icon: Icon(Icons.vpn_key),
            onPressed: () {},
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).accentColor,
          child: FutureBuilder(
              future: Provider.of<Credentials>(context, listen: false)
                  .loadCredentials(),
              builder: (context, snapshot) =>
                  snapshot.connectionState == ConnectionState.waiting
                      ? Center(child: CircularProgressIndicator())
                      : Consumer<Credentials>(
                          child: Center(
                            child: const Text(
                              "Press [+] to add a credential",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          builder: (context, credentials, child) =>
                              credentials.size() < 1
                                  ? child
                                  : ListView.builder(
                                      itemCount: credentials.size(),
                                      itemBuilder: (_, index) =>
                                          ChangeNotifierProvider.value(
                                        value: credentials.items[index],
                                        child: CredentialItem(),
                                      ),
                                    ),
                        )),
        ),
      ),
    );
  }
}
