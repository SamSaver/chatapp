import 'dart:developer';

import 'package:chatapp/Constants/AppColors.dart';
import 'package:chatapp/Constants/AppPaddings.dart';
import 'package:chatapp/Constants/Logging.dart';
import 'package:chatapp/Constants/MiscStrings.dart';
import 'package:chatapp/Model/UIHelper.dart';
import 'package:chatapp/Model/UserModel.dart';
import 'package:chatapp/UI/Pages/CompleteProfile.dart';
import 'package:chatapp/UI/Styling/AppTextStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/Constants/FirebaseCollections.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, Logging.incompleteData, MiscStrings.pleaseFillAllFields);
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, MiscStrings.passwordMismatch,
          MiscStrings.thePasswordsYouEnteredDoNotMatch);
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, MiscStrings.creatingNewAccount);

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(
          context, MiscStrings.anErrorOccured, ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        log(Logging.newUserCreated);
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return CompleteProfile(
                userModel: newUser, firebaseUser: credential!.user!);
          }),
        );
      });
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
                  SizedBox(height: 10),
                  TextField(
                    controller: cPasswordController,
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: MiscStrings.confirmPassword),
                  ),
                  SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: () {
                      checkValues();
                    },
                    color: AppColor.blue,
                    child: Text(MiscStrings.signUp),
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
            Text(MiscStrings.alreadyHaveAnAccount, style: AppTextStyles.font16),
            CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(MiscStrings.logIn, style: AppTextStyles.font16),
            ),
          ],
        ),
      ),
    );
  }
}
