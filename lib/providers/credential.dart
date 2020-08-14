import 'package:flutter/foundation.dart';
import 'dart:convert';

class Credential with ChangeNotifier {
  String id;
  String service;
  String owner;
  Map<String, dynamic> credentialData;
  int priority;

  Credential(
      {@required this.id,
      @required this.service,
      @required this.owner,
      @required this.credentialData,
      @required this.priority});

  Credential.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    service = map['service'];
    owner = map['owner'];
    credentialData = json.decode(map['credential_data']);
    priority = map['priority'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'service': service,
      'owner': owner,
      'credential_data': json.encode(credentialData),
      'priority': priority
    };

    return map;
  }
}
