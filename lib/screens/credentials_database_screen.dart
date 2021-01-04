import 'package:credivault_mobile/providers/subscription.dart';
import 'package:credivault_mobile/screens/rsa_loading_screen.dart';
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
  Future _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<dynamic> _loadData() async {
    await Provider.of<Subscription>(context, listen: false).loadSubscription();
    final bool isSub =
        Provider.of<Subscription>(context, listen: false).isSubscribed;
    return Future.wait([
      Provider.of<RSAProvider>(context, listen: false).getKeyPair(),
      Provider.of<Settings>(context, listen: false).loadSettings(),
      Provider.of<Biometrics>(context, listen: false).loadBiometrics(),
      Provider.of<Credentials>(context, listen: false).loadCredentials(isSub),
    ]);
  }

  Future<void> _showSubscriptionModal() async {
    final sub = Provider.of<Subscription>(context, listen: false);
    if (sub.available) {
      final price = sub.products[0].price;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Upgrade to Premium"),
          elevation: 5.0,
          content: Text(
              "With a montly subscription of $price, you can store and retreive an almost unlimited number of credentials!"),
          actions: <Widget>[
            FlatButton.icon(
                onPressed: () async {
                  await sub.buySubscription();
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.star),
                label: const Text("Subscribe Now"))
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Premium not available at this moment"),
          elevation: 5.0,
          content:
              Text("Unfortunately Premium is not available at this moment..."),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Dismiss"))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? RSALoadingScreen()
            : Scaffold(
                appBar: AppBar(
                  title: FittedBox(
                      child: Text(
                    "Credentials",
                    style: Theme.of(context).textTheme.headline1,
                  )),
                  actions: <Widget>[
                    Provider.of<Subscription>(context).isSubscribed ||
                            Provider.of<Credentials>(context).items.length < 5
                        ? IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => Navigator.of(context).pushNamed(
                                AddCredentialScreen.ROUTE_NAME,
                                arguments: {'editMode': false}),
                          )
                        : FlatButton(
                            child: const Text("Premium Upgrade"),
                            onPressed: () async =>
                                await _showSubscriptionModal(),
                          ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.of(context)
                          .pushNamed(SettingsScreen.ROUTE_NAME),
                    ),
                  ],
                ),
                drawer: MainDrawer(),
                body: SafeArea(
                  child: Container(
                      color: Theme.of(context).accentColor,
                      child: Consumer<Credentials>(
                        child: Center(
                          child: const Text(
                            "Press [+] to add a credential",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        builder: (context, credentials, child) => credentials
                                    .size() <
                                1
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
              ));
  }
}
