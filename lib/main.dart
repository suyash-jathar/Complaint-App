import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaint_app/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDOlfNBsm7BU_A5NdHjcm5vESuUo3V-U6o",
          appId: "1:697454804189:web:0a24fabe4b046d6b806f34",
          messagingSenderId: "697454804189",
          projectId: "complaint-project-dd99c",
          storageBucket: "complaint-project-dd99c.appspot.com"),
    );
  } else {
    await Firebase.initializeApp();
  }
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
