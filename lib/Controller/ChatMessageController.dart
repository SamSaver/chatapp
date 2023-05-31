import 'package:chatapp/Constants/FirebaseCollections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessageController extends GetxController {
  var documentList = [];
  ScrollController controller = ScrollController();
  int listLength = 10;
  final chatroomid;

  ChatMessageController({required this.chatroomid});

  void onInit() {
    generateList(chatroomid);
    addItems();
    super.onInit();
  }

  addItems() async {
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.position.pixels) {
        FirebaseFirestore.instance
            .collection(FirebaseCollections.chatrooms)
            .doc(chatroomid)
            .collection(FirebaseCollections.messages)
            .orderBy("createdon", descending: true)
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(20)
            .snapshots()
            .listen((event) {
          documentList.addAll(event.docs);
          update();
        });
      }
    });
  }

  generateList(chatroomid) async {
    FirebaseFirestore.instance
        .collection(FirebaseCollections.chatrooms)
        .doc(chatroomid)
        .collection(FirebaseCollections.messages)
        .orderBy("createdon", descending: true)
        .limit(20)
        .snapshots()
        .listen((event) {
      documentList = event.docs;
      update();
    });
  }
}
