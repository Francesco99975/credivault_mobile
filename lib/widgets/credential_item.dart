import 'package:credivault_mobile/providers/credential.dart';
import 'package:credivault_mobile/providers/credentials.dart';
import 'package:credivault_mobile/screens/add_credential_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CredentialItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final credential = Provider.of<Credential>(context);
    return Dismissible(
      key: ValueKey(credential.id),
      // background: Container(
      //   padding: const EdgeInsets.only(left: 20),
      //   margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      //   color: Colors.blue,
      //   child: Icon(
      //     Icons.edit,
      //     color: Colors.white,
      //     size: 40,
      //   ),
      //   alignment: Alignment.centerLeft,
      // ),
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you want to delete this credential ?"),
            actions: <Widget>[
              FlatButton(
                child: const Text("No"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: const Text("Yes"),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          Provider.of<Credentials>(context, listen: false)
              .deleteCredential(credential.id);
        }
      },
      child: Card(
        elevation: 5,
        color: Theme.of(context).primaryColor,
        child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.lock,
                size: 28,
                color: Colors.greenAccent[700],
              ),
            ),
            title: Text(credential.service),
            subtitle: Text(credential.owner),
            trailing: Container(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.amber,
                    onPressed: () async => await Navigator.of(context)
                        .pushNamed(AddCredentialScreen.ROUTE_NAME,
                            arguments: {'editMode': true, 'id': credential.id}),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    color: Theme.of(context).accentColor,
                    onPressed: () {},
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
