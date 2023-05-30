import 'dart:developer';

import 'package:chatapp/Constants/AppColors.dart';
import 'package:chatapp/Constants/AppPaddings.dart';
import 'package:chatapp/Constants/FirebaseCollections.dart';
import 'package:chatapp/Constants/Logging.dart';
import 'package:chatapp/Constants/MiscStrings.dart';
import 'package:chatapp/Controller/ProfileController.dart';
import 'package:chatapp/main.dart';
import 'package:chatapp/Model/ChatRoomModel.dart';
import 'package:chatapp/Model/UserModel.dart';
import 'package:chatapp/UI/Pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  ProfileController profileController = Get.find();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(FirebaseCollections.chatrooms)
        .where("participants.${profileController.userModel.uid}",
            isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          profileController.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection(FirebaseCollections.chatrooms)
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log(Logging.newChatRoomCreated);
    }

    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MiscStrings.search),
      ),
      body: SafeArea(
        child: Container(
          padding: AppPaddings.paddingH20V10,
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: MiscStrings.emailAdress),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: AppColor.blue,
                child: Text(MiscStrings.search),
              ),
              SizedBox(height: 20),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(FirebaseCollections.users)
                      .where("email", isEqualTo: searchController.text)
                      .where("email",
                          isNotEqualTo: profileController.userModel.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);

                          return ListTile(
                            onTap: () async {
                              ChatRoomModel? chatroomModel =
                                  await getChatroomModel(searchedUser);

                              if (chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ChatRoomPage(
                                    targetUser: searchedUser,
                                    // userModel: widget.userModel,
                                    // firebaseUser: widget.firebaseUser,
                                    chatroom: chatroomModel,
                                  );
                                }));
                              }
                            },
                            // leading: CircleAvatar(
                            //   backgroundImage: NetworkImage(searchedUser.profilepic!),
                            //   backgroundColor: Colors.grey[500],
                            // ),
                            title: Text(searchedUser.fullname!),
                            subtitle: Text(searchedUser.email!),
                            trailing: Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return Text(MiscStrings.noResultsFound);
                        }
                      } else if (snapshot.hasError) {
                        return Text(MiscStrings.anErrorOccured);
                      } else {
                        return Text(MiscStrings.noResultsFound);
                      }
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
