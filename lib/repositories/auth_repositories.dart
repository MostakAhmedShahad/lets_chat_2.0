import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<void> signUp(String email, String password) async {
  //   await _auth.createUserWithEmailAndPassword(email: email, password: password);
  // }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
  Future<void> signUp(String email, String password) async {
  try {
    // Create user in Firebase Authentication
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user data in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email,
    });

    print('User signed up and data stored in Firestore');
  } catch (e) {
    print('Error signing up: $e');
    throw Exception('Failed to sign up: $e');
  }
}

  Stream<User?> get user => _auth.authStateChanges();
}