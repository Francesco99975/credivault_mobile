import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/biometrics_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  static const ROUTE_NAME = "/settings";
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var _isLoading = false;
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
                    onChanged: Provider.of<Biometrics>(context, listen: false)
                            .canUseBiometrics
                        ? (_) async =>
                            await Provider.of<Settings>(context, listen: false)
                                .toggleAuthMode()
                        : null),
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
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: "Enter current Master password"),
                              ),
                            TextField(
                              controller: _masterController,
                              obscureText: true,
                              decoration: InputDecoration(
                                  labelText: "Enter a new Master password"),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RaisedButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = !_isLoading;
                                });
                                if (!settings.unset()) {
                                  if (_masterController.text
                                      .trim()
                                      .isNotEmpty) {
                                    await Provider.of<Settings>(context,
                                            listen: false)
                                        .setMasterPassword(
                                            _masterController.text.trim());
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("An Error Occurred"),
                                        content: const Text(
                                            "Password could not be set"),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: const Text("Dismiss"),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  print("Thhere");
                                  final currentMasterPassword =
                                      await Provider.of<Settings>(context,
                                              listen: false)
                                          .masterPassword;
                                  if (_masterController.text
                                          .trim()
                                          .isNotEmpty &&
                                      _remasterController.text.trim() ==
                                          currentMasterPassword) {
                                    await Provider.of<Settings>(context,
                                            listen: false)
                                        .setMasterPassword(
                                            _masterController.text.trim());
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("An Error Occurred"),
                                        content: const Text(
                                            "Password could not be set"),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: const Text("Dismiss"),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                }
                                setState(() {
                                  _isLoading = !_isLoading;
                                });
                                Navigator.of(context).pop();
                              },
                              child: !_isLoading
                                  ? const Text("SET MASTER PASSWORD")
                                  : CircularProgressIndicator(),
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
