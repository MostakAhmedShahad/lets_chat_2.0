import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc/auth_bloc.dart';
import 'bloc/chat_bloc/chat_bloc.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD3QYhCfBogKt_pnssg65cJ1lrXnQlwhzg", // Replace with your API key
      authDomain: "lets-chat-65327.firebaseapp.com", // Replace with your auth domain
      projectId: "lets-chat-65327", // Replace with your project ID
      storageBucket: "lets-chat-65327.appspot.com", // Replace with your storage bucket
      messagingSenderId: "965207828472", // Replace with your messaging sender ID
      appId: "1:965207828472:web:5e31c842d8835bed51d80d", // Replace with your app ID
      measurementId: "G-WECYHB6BMN", // Replace with your measurement ID
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ChatBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),
      ),
    );
  }
}