import 'package:credivault_mobile/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const ROUTE_NAME = "/settings";
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final _masterController = TextEditingController();
    final _remasterController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Consumer<Settings>(
            builder: (_, settings, __) => Column(
              children: <Widget>[
                SwitchListTile.adaptive(
                    title: const Text("Authentication Type"),
                    subtitle: settings.authMode
                        ? const Text("Fingerprint")
                        : const Text("Master Password"),
                    value: settings.authMode,
                    onChanged: (_) async =>
                        await Provider.of<Settings>(context, listen: false)
                            .toggleAuthMode()),
                SizedBox(
                  height: 10,
                ),
                if (!settings.authMode)
                  Card(
                    color: Theme.of(context).primaryColor,
                    margin: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Set Master Password",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 22),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            if (settings.unset())
                              TextField(
                                controller: _remasterController,
                                decoration: InputDecoration(
                                    labelText: "Enter current Master password"),
                              ),
                            TextField(
                              controller: _masterController,
                              decoration: InputDecoration(
                                  labelText: "Enter a new Master password"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RaisedButton(
                              onPressed: () {},
                              child: const Text("SET MASTER PASSWORD"),
                              color: Theme.of(context).accentColor,
                              textColor: Colors.amber,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
