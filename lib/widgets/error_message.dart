import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String _errorMessage;

  ErrorMessage(this._errorMessage);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "An error occurred",
        textAlign: TextAlign.center,
      ),
      content: Text(
        _errorMessage,
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Dismiss"),
          textColor: Theme.of(context).errorColor,
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }
}
