import 'dart:convert';
import 'dart:io';
import 'package:credivault_mobile/widgets/double_field.dart';
import 'package:flutter/material.dart';
import 'package:credivault_mobile/providers/credential.dart';
import 'package:credivault_mobile/providers/credentials.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AddCredentialScreen extends StatelessWidget {
  static const ROUTE_NAME = '/add-credential';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    return Scaffold(
        appBar: AppBar(
          title: Text("Add a new credential"),
          centerTitle: true,
          actions: <Widget>[
            if (args['editMode'])
              IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {},
              )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              color: Theme.of(context).accentColor,
            ),
            Container(
              margin: const EdgeInsets.all(18.0),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AddCredentialForm(args),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class AddCredentialForm extends StatefulWidget {
  final Map<String, dynamic> args;

  AddCredentialForm(this.args);
  @override
  _AddCredentialFormState createState() => _AddCredentialFormState();
}

class _AddCredentialFormState extends State<AddCredentialForm> {
  static const _url = "https://bme-encdec-server.herokuapp.com";
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  Size deviceSize;
  final _uuid = Uuid();

  Credential crd; //Update only
  final _ownerController = TextEditingController();
  final _serviceController = TextEditingController();

  String _owner = "";
  String _service = "";
  Map<String, dynamic> _credetialData = {};

  List<TextEditingController> _keyControllers = [];
  List<TextEditingController> _valueControllers = [];

  List<Widget> _credentialInputs = [];

  void _refreshInputs() {
    for (var i = 0; i < _credentialInputs.length; ++i) {
      _credentialInputs[i] = DoubleField(
        index: i,
        isOne: _credentialInputs.length < 2,
        keyControllers: _keyControllers,
        valueControllers: _valueControllers,
        deviceSize: deviceSize,
        fn: _setInputs,
      );
    }
  }

  void _setInputs(int index) {
    setState(() {
      _credentialInputs.removeAt(index);
      _keyControllers.removeAt(index);
      _valueControllers.removeAt(index);

      print(_credentialInputs.length);

      _refreshInputs();
    });
  }

  Widget _getCredentialInput(int index, {String key = "", dynamic value = ""}) {
    _keyControllers.add(TextEditingController(text: key));
    _valueControllers.add(TextEditingController(text: value));
    return DoubleField(
      index: index,
      isOne: _credentialInputs.length + 1 < 2,
      keyControllers: _keyControllers,
      valueControllers: _valueControllers,
      deviceSize: deviceSize,
      fn: _setInputs,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      deviceSize = MediaQuery.of(context).size;
      if (widget.args['editMode']) {
        crd = Provider.of<Credentials>(context, listen: false)
            .findById(widget.args['id']);
        setState(() {
          _ownerController.text = crd.owner;
          _serviceController.text = crd.service;
          crd.credentialData.forEach((key, value) {
            _credentialInputs.add(_getCredentialInput(_credentialInputs.length,
                key: key, value: value));
          });
          _refreshInputs();
        });
      } else {
        setState(() {
          _credentialInputs.add(_getCredentialInput(0));
        });
      }
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = !_isLoading;
      });
      _formKey.currentState.save();
      for (var i = 0; i < _credentialInputs.length; ++i) {
        _credetialData
            .addAll({_keyControllers[i].text: _valueControllers[i].text});
      }

      final res = await http.post("$_url/encrypt",
          body: json.encode(_credetialData),
          headers: {HttpHeaders.contentTypeHeader: "application/json"});

      final _encryptedCredetialData =
          json.decode(res.body) as Map<String, dynamic>;

      if (!widget.args['editMode']) {
        final lastIndex =
            Provider.of<Credentials>(context, listen: false).size();
        await Provider.of<Credentials>(context, listen: false).addCredential(
            Credential(
                id: _uuid.v4(),
                owner: _owner,
                service: _service,
                credentialData: _encryptedCredetialData,
                priority: lastIndex));
      } else {
        await Provider.of<Credentials>(context, listen: false).updateCredential(
            crd.id,
            Credential(
                id: crd.id,
                owner: _owner,
                service: _service,
                credentialData: _encryptedCredetialData,
                priority: crd.priority));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            color: Theme.of(context).primaryColor,
            elevation: 6.0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        autocorrect: false,
                        controller: _ownerController,
                        decoration:
                            InputDecoration(labelText: "Credential Owner"),
                        validator: (value) => value.trim().isEmpty
                            ? "Enter a owner please"
                            : null,
                        onSaved: (newValue) => _owner = newValue,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        autocorrect: false,
                        controller: _serviceController,
                        decoration: InputDecoration(labelText: "Service"),
                        validator: (value) => value.trim().isEmpty
                            ? "Enter a service please"
                            : null,
                        onSaved: (newValue) => _service = newValue,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 250,
                        child: ListView.builder(
                            itemCount: _credentialInputs.length,
                            itemBuilder: (context, index) =>
                                _credentialInputs[index]),
                      ),
                      if (!_isLoading)
                        Center(
                          child: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                _credentialInputs.add(_getCredentialInput(
                                    _credentialInputs.length));
                                for (var i = _credentialInputs.length - 2;
                                    i >= 0;
                                    --i) {
                                  _credentialInputs[i] = DoubleField(
                                    index: i,
                                    isOne: _credentialInputs.length + 1 < 2,
                                    keyControllers: _keyControllers,
                                    valueControllers: _valueControllers,
                                    deviceSize: deviceSize,
                                    fn: _setInputs,
                                  );
                                }
                              });
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton.icon(
              onPressed: _isLoading ? () {} : _saveForm,
              elevation: 3.0,
              icon: Icon(Icons.lock),
              color: Colors.amber,
              textColor: Theme.of(context).accentColor,
              label: _isLoading
                  ? CircularProgressIndicator()
                  : const Text("STORE CREDENTIAL"))
        ],
      ),
    );
  }
}
