import 'dart:developer';

import 'package:chatapp/Constants/AppColors.dart';
import 'package:chatapp/Constants/AppMargins.dart';
import 'package:chatapp/Constants/AppPaddings.dart';
import 'package:chatapp/Constants/MiscDouble.dart';
import 'package:chatapp/Constants/MiscStrings.dart';
import 'package:chatapp/Controller/ChatMessageController.dart';
import 'package:chatapp/Controller/ProfileController.dart';
import 'package:chatapp/UI/Styling/AppTextStyles.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/Model/ChatRoomModel.dart';
import 'package:chatapp/Model/MessageModel.dart';
import 'package:chatapp/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/Constants/FirebaseCollections.dart';
import 'package:chatapp/Constants/Logging.dart';
import 'package:chatapp/UI/Widgets/SendButton.dart';
import 'package:get/get.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;

  const ChatRoomPage(
      {Key? key, required this.targetUser, required this.chatroom})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  ProfileController profileController = Get.find();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: profileController.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection(FirebaseCollections.chatrooms)
          .doc(widget.chatroom.chatroomid)
          .collection(FirebaseCollections.messages)
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection(FirebaseCollections.chatrooms)
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log(Logging.messageSent);
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatMessageController chatMessageController =
        Get.put(ChatMessageController(chatroomid: widget.chatroom.chatroomid));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            SizedBox(width: 10),
            Text(
              widget.targetUser.fullname.toString(),
              style: AppTextStyles.font16White,
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              // This is where the chats will go
              Expanded(
                child: Container(
                    padding: AppPaddings.paddingH10,
                    child: GetBuilder(
                      init: chatMessageController,
                      builder: (value) => ListView.builder(
                        reverse: true,
                        controller: chatMessageController.controller,
                        itemCount: chatMessageController.documentList.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              chatMessageController.documentList[index].data()
                                  as Map<String, dynamic>);

                          return Row(
                            mainAxisAlignment: (currentMessage.sender ==
                                    profileController.userModel.uid)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: AppMargins.marginV2,
                                padding: AppPaddings.paddingV10H10,
                                decoration: BoxDecoration(
                                  color: (currentMessage.sender ==
                                          profileController.userModel.uid)
                                      ? AppColor.grey
                                      : AppColor.blue,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  currentMessage.text.toString(),
                                  style: AppTextStyles.fontWhite,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )),
              ),

              Container(
                color: AppColor.grey200,
                padding: AppPaddings.paddingH15V5,
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: MiscStrings.enterMessage),
                      ),
                    ),
                    SendButton(sendMessage: sendMessage)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
