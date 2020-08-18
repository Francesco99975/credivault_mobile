import 'package:credivault_mobile/providers/biometrics_provider.dart';
import 'package:credivault_mobile/providers/credentials.dart';
import 'package:credivault_mobile/providers/settings_provider.dart';
import 'package:credivault_mobile/screens/add_credential_screen.dart';
import 'package:credivault_mobile/screens/settings_screen.dart';
import 'package:credivault_mobile/widgets/credential_item.dart';
import 'package:credivault_mobile/widgets/main_drawer.dart';
import 'package:draggable_flutter_list/draggable_flutter_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CredentialsDatabaseScreen extends StatefulWidget {
  static const ROUTE_NAME = '/credentials-database';

  @override
  _CredentialsDatabaseScreenState createState() =>
      _CredentialsDatabaseScreenState();
}

class _CredentialsDatabaseScreenState extends State<CredentialsDatabaseScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showSnackBar() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Copied to Clipboard!",
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 1),
        onVisible: () {
          Future.delayed(Duration(seconds: 1))
              .then((value) => _scaffoldKey.currentState.hideCurrentSnackBar());
        },
        backgroundColor: Colors.black));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
            icon: const Icon(Icons.vpn_key),
            onPressed: () =>
                Navigator.of(context).pushNamed(SettingsScreen.ROUTE_NAME),
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: SafeArea(
        child: Container(
          color: Theme.of(context).accentColor,
          child: FutureBuilder(
              future: Future.wait([
                Provider.of<Settings>(context, listen: false).loadSettings(),
                Provider.of<Biometrics>(context, listen: false)
                    .loadBiometrics(),
                Provider.of<Credentials>(context, listen: false)
                    .loadCredentials(),
              ]),
              builder: (context, snapshot) => snapshot.connectionState ==
                      ConnectionState.waiting
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
                              : DragAndDropList(
                                  credentials.size(),
                                  itemBuilder: (_, index) =>
                                      ChangeNotifierProvider.value(
                                    value: credentials.items[index],
                                    child: CredentialItem(_showSnackBar),
                                  ),
                                  dragElevation: 8.0,
                                  canBeDraggedTo: (oldIndex, newIndex) => true,
                                  onDragFinish: (oldIndex, newIndex) =>
                                      credentials.rearrange(oldIndex, newIndex),
                                ),
                    )),
        ),
      ),
    );
  }
}
