import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/credentials.dart';

class DoubleField extends StatelessWidget {
  final int index;
  final bool isOne;
  final List<TextEditingController> keyControllers;
  final List<TextEditingController> valueControllers;
  final Size deviceSize;
  final Function fn;

  DoubleField(
      {@required this.index,
      @required this.isOne,
      @required this.keyControllers,
      @required this.valueControllers,
      @required this.deviceSize,
      @required this.fn});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: ValueKey(index),
      children: <Widget>[
        Container(
          width: deviceSize.width / 2 - 70,
          child: TextFormField(
            controller: keyControllers[index],
            decoration: InputDecoration(
              labelText: "key",
            ),
            autocorrect: false,
            validator: (value) =>
                value.trim().isEmpty ? "Please Enter a key" : null,
          ),
        ),
        const SizedBox(
          width: 8.0,
        ),
        Container(
          width: deviceSize.width / 2 - 70,
          child: TextFormField(
            controller: valueControllers[index],
            obscureText: Provider.of<Credentials>(context).visible(),
            decoration: InputDecoration(labelText: "value"),
            autocorrect: false,
            validator: (value) =>
                value.trim().isEmpty ? "Please Enter a value" : null,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.remove,
            color: isOne ? Colors.grey : Colors.red,
          ),
          onPressed: isOne ? null : () => fn(index),
        )
      ],
    );
  }
}
