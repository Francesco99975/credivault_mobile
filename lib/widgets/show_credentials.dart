import 'dart:convert';
import 'dart:io';
import 'package:credivault_mobile/providers/biometrics_provider.dart';
import 'package:credivault_mobile/providers/settings_provider.dart';
import 'package:credivault_mobile/screens/credentials_database_screen.dart';
import 'package:credivault_mobile/screens/loading_screen.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:credivault_mobile/providers/credential.dart';
import 'package:provider/provider.dart';

class ShowCredentials extends StatefulWidget {
  final Credential _credential;

  ShowCredentials(this._credential);
  @override
  _ShowCredentialsState createState() => _ShowCredentialsState();
}

class _ShowCredentialsState extends State<ShowCredentials> {
  static const _url = "https://bme-encdec-server.herokuapp.com";
  Map<String, dynamic> _decryptedCredentials;

  Future<void> _decryptCredentials() async {
    if (Provider.of<Settings>(context, listen: false).authMode) {
      Navigator.pushNamed(context, LoadingScreen.ROUTE_NAME);
    }
    final res = await http.post("$_url/decrypt",
        body: json.encode(widget._credential.credentialData),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    _decryptedCredentials = json.decode(res.body) as Map<String, dynamic>;
    Navigator.pushNamed(context, CredentialsDatabaseScreen.ROUTE_NAME);
  }

  Future<bool> _requestPassword(String req) async {
    Navigator.pushNamed(context, LoadingScreen.ROUTE_NAME);
    final password =
        await Provider.of<Settings>(context, listen: false).masterPassword;
    if (req.trim() == password) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.visibility),
      color: Theme.of(context).accentColor,
      onPressed: () async {
        if (Provider.of<Settings>(context, listen: false).authMode) {
          final res = await Provider.of<Biometrics>(context, listen: false)
              .fingerprintAuth();
          if (!res) return;
        } else if (Provider.of<Settings>(context, listen: false).unset()) {
          final _controller = TextEditingController();
          var access = false;
          final String req = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                "Enter Master Password",
                textAlign: TextAlign.center,
              ),
              content: TextField(
                decoration: InputDecoration(labelText: "Enter Master Password"),
                obscureText: true,
                controller: _controller,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Submit"),
                  onPressed: () async {
                    Navigator.of(context).pop(_controller.text);
                  },
                )
              ],
            ),
          );

          access = await _requestPassword(req);

          if (!access) {
            Navigator.pushNamed(context, CredentialsDatabaseScreen.ROUTE_NAME);
            await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: const Text("Invalid Password"),
                      content:
                          const Text("The password you entered is not correct"),
                    ));
            return;
          }
        }
        await _decryptCredentials();
        await showDialog(
            context: context,
            builder: (context) {
              List<String> keys = _decryptedCredentials.keys.toList();
              List<dynamic> values = _decryptedCredentials.values.toList();
              return AlertDialog(
                title: Text(
                  "Stored Credentials for ${widget._credential.owner}'s ${widget._credential.service}",
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Theme.of(context).accentColor,
                content: Container(
                  height: 200,
                  width: 600,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _decryptedCredentials.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        color: Theme.of(context).primaryColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.lock_open,
                              size: 28,
                              color: Colors.red,
                            ),
                          ),
                          title: Text(keys[index]),
                          subtitle: Text(values[index]),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.content_copy,
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: values[index]));
                              Flushbar(
                                title: "Operation Successfull",
                                message: "Copied to Clipboard!",
                                duration: Duration(seconds: 2),
                              )..show(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: const Text("Close"),
                    onPressed: () {
                      keys = null;
                      values = null;
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      },
    );
  }
}
