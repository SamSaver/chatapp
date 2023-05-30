import 'dart:developer';

import 'package:chatapp/Constants/AppColors.dart';
import 'package:chatapp/Constants/AppPaddings.dart';
import 'package:chatapp/Constants/FirebaseCollections.dart';
import 'package:chatapp/Constants/Logging.dart';
import 'package:chatapp/Constants/MiscStrings.dart';
import 'package:chatapp/Model/UIHelper.dart';
import 'package:chatapp/Model/UserModel.dart';
import 'package:chatapp/UI/Pages/HomePage.dart';
import 'package:chatapp/UI/Pages/SignUpPage.dart';
import 'package:chatapp/UI/Styling/AppTextStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, Logging.incompleteData, MiscStrings.pleaseFillAllFields);
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, MiscStrings.loggingIn);

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      // Close the loading dialog
      Navigator.pop(context);

      // Show Alert Dialog
      UIHelper.showAlertDialog(
          context, MiscStrings.anErrorOccured, ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Go to HomePage
      log(Logging.loggingInSuccessful);

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return HomePage(
              userModel: userModel, firebaseUser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: AppPaddings.paddingH40,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    MiscStrings.chatApp,
                    style: AppTextStyles.fontBlueBold45,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration:
                        InputDecoration(labelText: MiscStrings.emailAdress),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: MiscStrings.password),
                  ),
                  SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: AppColor.blue,
                    child: Text(MiscStrings.logIn),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(MiscStrings.dontHaveAnAccount, style: AppTextStyles.font16),
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return SignUpPage();
                  }),
                );
              },
              child: Text(MiscStrings.signUp, style: AppTextStyles.font16),
            ),
          ],
        ),
      ),
    );
  }
}
