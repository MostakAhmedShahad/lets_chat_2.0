 
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final DateTime? lastMessageTimestamp; 

  UserModel({required this.uid, required this.email,required this.lastMessageTimestamp});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      lastMessageTimestamp: data['lastMessageTimestamp'] != null
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : null,
    );
  }
}

 