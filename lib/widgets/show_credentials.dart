import 'dart:convert';
import 'dart:io';
import 'package:credivault_mobile/screens/credentials_database_screen.dart';
import 'package:credivault_mobile/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:credivault_mobile/providers/credential.dart';

class ShowCredentials extends StatefulWidget {
  final Credential _credential;
  final Function _showSnackBar;

  ShowCredentials(this._credential, this._showSnackBar);
  @override
  _ShowCredentialsState createState() => _ShowCredentialsState();
}

class _ShowCredentialsState extends State<ShowCredentials> {
  static const _url = "https://bme-encdec-server.herokuapp.com";
  Map<String, dynamic> _decryptedCredentials;

  Future<void> _decryptCredentials() async {
    Navigator.pushNamed(context, LoadingScreen.ROUTE_NAME);
    final res = await http.post("$_url/decrypt",
        body: json.encode(widget._credential.credentialData),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    _decryptedCredentials = json.decode(res.body) as Map<String, dynamic>;
    Navigator.pushNamed(context, CredentialsDatabaseScreen.ROUTE_NAME);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.visibility),
      color: Theme.of(context).accentColor,
      onPressed: () async {
        await _decryptCredentials();
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
                  List<String> keys = _decryptedCredentials.keys.toList();
                  List<dynamic> values = _decryptedCredentials.values.toList();

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
                          widget._showSnackBar();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
