import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:draggable_flutter_list/draggable_flutter_list.dart';
import '../providers/biometrics_provider.dart';
import '../providers/credentials.dart';
import '../providers/rsa_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/add_credential_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/credential_item.dart';
import '../widgets/main_drawer.dart';

class CredentialsDatabaseScreen extends StatefulWidget {
  static const ROUTE_NAME = '/credentials-database';

  @override
  _CredentialsDatabaseScreenState createState() =>
      _CredentialsDatabaseScreenState();
}

class _CredentialsDatabaseScreenState extends State<CredentialsDatabaseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Credentials"),
        actions: <Widget>[
          //if(paid || Provider.of<Credentials>(context).items.length < 5)
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).pushNamed(
                AddCredentialScreen.ROUTE_NAME,
                arguments: {'editMode': false}),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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
                Provider.of<RSAProvider>(context, listen: false).getKeyPair(),
                Provider.of<Settings>(context, listen: false).loadSettings(),
                Provider.of<Biometrics>(context, listen: false)
                    .loadBiometrics(),
                Provider.of<Credentials>(context, listen: false)
                    .loadCredentials(),
              ]),
              builder: (context, snapshot) => snapshot.connectionState ==
                      ConnectionState.waiting
                  ? Column(
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
                        const Text("This may take a minute...",
                            textAlign: TextAlign.center)
                      ],
                    )
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
                                    child: CredentialItem(),
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
