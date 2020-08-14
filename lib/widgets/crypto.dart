import 'dart:convert';
import 'dart:io';
import 'package:credivault_mobile/widgets/error_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Crypto extends StatefulWidget {
  @override
  _CryptoState createState() => _CryptoState();
}

class _CryptoState extends State<Crypto> {
  static const _url = "https://bme-encdec-server.herokuapp.com";
  final _textController = TextEditingController();
  var _isEncrypt = true;
  var _isLoading = false;

  Future<void> _encrypt(String message) async {
    setState(() {
      _isLoading = !_isLoading;
    });
    final res = await http.post("$_url/encrypt",
        body: json.encode({'data': message}),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});
    final extractedData = json.decode(res.body);

    if (res.statusCode == 200) {
      final encryptedData = extractedData['data'];
      setState(() {
        _isLoading = !_isLoading;
        _textController.text = encryptedData;
      });
    } else {
      await showDialog(
        context: context,
        builder: (context) => ErrorMessage(extractedData['error']),
      );
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  Future<void> _decrypt(String message) async {
    setState(() {
      _isLoading = !_isLoading;
    });
    final res = await http.post("$_url/decrypt",
        body: json.encode({'data': message}),
        headers: {HttpHeaders.contentTypeHeader: "application/json"});

    final extractedData = json.decode(res.body);

    if (res.statusCode == 200) {
      final decryptedData = extractedData['data'];
      setState(() {
        _isLoading = !_isLoading;
        _textController.text = decryptedData;
      });
    } else {
      await showDialog(
        context: context,
        builder: (context) => ErrorMessage(extractedData['error']),
      );
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      child: Center(
        child: Container(
          height: 320,
          padding: const EdgeInsets.all(22.0),
          child: Card(
            elevation: 5,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(
                        _isEncrypt ? "Encrypt" : "Decrypt",
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: "Enter text to " +
                              (_isEncrypt ? "encrypt" : "decrypt"),
                        )),
                    const SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: !_isLoading
                          ? Text(_isEncrypt ? "Encrypt" : "Decrypt")
                          : CircularProgressIndicator(
                              backgroundColor: Colors.amber,
                            ),
                      onPressed: () {
                        if (_textController.text.trim().isNotEmpty &&
                            !_isLoading) {
                          try {
                            if (_isEncrypt) {
                              _encrypt(_textController.text);
                            } else {
                              _decrypt(_textController.text);
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    if (!_isLoading)
                      FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              _isEncrypt = !_isEncrypt;
                            });
                          },
                          icon: Icon(_isEncrypt ? Icons.lock_open : Icons.lock),
                          label: Text(_isEncrypt
                              ? "Switch To Decryption"
                              : "Switch To Encryption"))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
