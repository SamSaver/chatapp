import 'package:chatapp/Model/FirebaseHelper.dart';
import 'package:chatapp/Model/UserModel.dart';
import 'package:chatapp/UI/Pages/CompleteProfile.dart';
import 'package:chatapp/UI/Pages/HomePage.dart';
import 'package:chatapp/UI/Pages/LoginPage.dart';
import 'package:chatapp/UI/Pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:chatapp/firebase_options.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(MyApp());
    }
  } else {
    // Not logged in
    runApp(MyApp());
  }
}

// Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// Already Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
