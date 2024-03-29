import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/biometrics_provider.dart';
import '../providers/credential.dart';
import '../providers/settings_provider.dart';
import '../screens/add_credential_screen.dart';
import '../screens/loading_screen.dart';

class EditCredentials extends StatefulWidget {
  final Credential _credential;

  EditCredentials(this._credential);
  @override
  _EditCredentialsState createState() => _EditCredentialsState();
}

class _EditCredentialsState extends State<EditCredentials> {
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
        icon: Icon(Icons.edit),
        color: Colors.amber,
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
                  decoration:
                      InputDecoration(labelText: "Enter Master Password"),
                  obscureText: true,
                  controller: _controller,
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      Navigator.of(context).pop(_controller.text);
                    },
                  )
                ],
              ),
            );

            if (req == null) return;

            access = await _requestPassword(req == null ? "" : req);

            if (!access) {
              Navigator.pushReplacementNamed(context, '/');
              await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text("Invalid Password"),
                        content: const Text(
                            "The password you entered is not correct"),
                      ));
              return;
            }
          }
          Navigator.pushReplacementNamed(context, '/');
          await Navigator.of(context).pushNamed(AddCredentialScreen.ROUTE_NAME,
              arguments: {'editMode': true, 'id': widget._credential.id});
        });
  }
}
