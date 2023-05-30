import 'package:chatapp/Model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  var firebaseUser;
  var userModel;

  void setUser(UserModel userModel, User firebaseUser) {
    this.userModel = userModel;
    this.firebaseUser = firebaseUser;
    update();
  }

  // Getters for user and firebase user
  UserModel get getUserModel => userModel;
  User get getFirebaseUser => firebaseUser;
}
