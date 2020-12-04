import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/rsa_provider.dart';
import '../widgets/double_field.dart';
import '../providers/credential.dart';
import '../providers/credentials.dart';

class AddCredentialScreen extends StatelessWidget {
  static const ROUTE_NAME = '/add-credential';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            child: Text(
              args['editMode'] ? "Update Credential" : "Add a new Credential",
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Provider.of<Credentials>(context).visible()
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () => Provider.of<Credentials>(context, listen: false)
                  .toggleVisible(),
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
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  Size deviceSize;
  final _uuid = Uuid();
  Future<void> _data;

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

  Future<void> _loadData() async {
    return Future(() async {
      deviceSize = MediaQuery.of(context).size;
      if (widget.args['editMode']) {
        crd = Provider.of<Credentials>(context, listen: false)
            .findById(widget.args['id']);
        _ownerController.text = crd.owner;
        _serviceController.text = crd.service;
        final decryptedCredentialData = crd.credentialData.map((key, value) =>
            MapEntry(
                key,
                Provider.of<RSAProvider>(context, listen: false)
                    .decrypt(value)));
        decryptedCredentialData.forEach((key, value) {
          _credentialInputs.add(_getCredentialInput(_credentialInputs.length,
              key: key, value: value));
        });
        _refreshInputs();
        print("Done");
      } else {
        _credentialInputs.add(_getCredentialInput(0));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _data = _loadData();
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

      final _encryptedCredetialData = _credetialData.map((key, value) =>
          MapEntry(key,
              Provider.of<RSAProvider>(context, listen: false).encrypt(value)));

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
    return FutureBuilder(
      initialData: false,
      future: _data,
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.waiting
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.amber,
              ),
            )
          : SingleChildScrollView(
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
                                decoration: InputDecoration(
                                    labelText: "Credential Owner"),
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
                                decoration:
                                    InputDecoration(labelText: "Service"),
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
                                        _credentialInputs.add(
                                            _getCredentialInput(
                                                _credentialInputs.length));
                                        for (var i =
                                                _credentialInputs.length - 2;
                                            i >= 0;
                                            --i) {
                                          _credentialInputs[i] = DoubleField(
                                            index: i,
                                            isOne:
                                                _credentialInputs.length + 1 <
                                                    2,
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
                          : widget.args['editMode']
                              ? Text(
                                  "UPDATE CREDENTIAL",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              : Text("STORE CREDENTIAL",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
            ),
    );
  }
}
