import 'package:chatapp/Constants/AppColors.dart';
import 'package:chatapp/Constants/FirebaseCollections.dart';
import 'package:chatapp/Constants/MiscStrings.dart';
import 'package:chatapp/Model/ChatRoomModel.dart';
import 'package:chatapp/Model/FirebaseHelper.dart';
import 'package:chatapp/Model/UIHelper.dart';
import 'package:chatapp/Model/UserModel.dart';
import 'package:chatapp/UI/Pages/ChatRoomPage.dart';
import 'package:chatapp/UI/Pages/LoginPage.dart';
import 'package:chatapp/UI/Pages/SearchPage.dart';
import 'package:chatapp/UI/Styling/AppTextStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(MiscStrings.chatApp),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(FirebaseCollections.chatrooms)
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future:
                            FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel,
                                        firebaseUser: widget.firebaseUser,
                                        userModel: widget.userModel,
                                        targetUser: targetUser,
                                      );
                                    }),
                                  );
                                },
                                // leading: CircleAvatar(
                                //   backgroundImage: NetworkImage(
                                //       targetUser.profilepic.toString()),
                                // ),
                                title: Text(targetUser.fullname.toString()),
                                subtitle: (chatRoomModel.lastMessage
                                            .toString() !=
                                        "")
                                    ? Text(chatRoomModel.lastMessage.toString())
                                    : Text(
                                        MiscStrings.sayHiToYourNewFriend,
                                        style: AppTextStyles.fontBlue,
                                      ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return Center(
                    child: Text(MiscStrings.noChatsYet),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
