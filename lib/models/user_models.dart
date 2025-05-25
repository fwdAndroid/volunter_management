import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String uuid;
  String password;
  String type;
  String fullName;

  UserModel({
    required this.uuid,
    required this.email,
    required this.fullName,
    required this.password,
    required this.type,
  });

  ///Converting OBject into Json Object
  Map<String, dynamic> toJson() => {
    'email': email,
    'uid': uuid,
    'password': password,
    'type': type,
    'fullName': fullName,
  };

  ///
  static UserModel fromSnap(DocumentSnapshot snaps) {
    var snapshot = snaps.data() as Map<String, dynamic>;

    return UserModel(
      email: snapshot['email'],
      uuid: snapshot['uid'],
      password: snapshot['password'],
      type: snapshot['type'],

      fullName: snapshot['fullName'],
    );
  }
}
