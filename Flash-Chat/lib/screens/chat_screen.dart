import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/utils/constants.dart';
import 'package:flutterchat/screens/welcome_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  final String receiver;
  final String sender;
  final String chatId;
  final TextEditingController _controller;
  final String dispname;

  ChatScreen(this._controller, this.receiver, this.sender,this.chatId, this.dispname, {super.key});

  late String message;

  late bool isMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  Navigator.pushNamed(context, WelcomeScreen.id);
                } else {
                  throw ("Invalid Request");
                }
              }),
        ],
        title: Text(dispname),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('messages').doc(chatId).collection('message').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: Colors.blueAccent,
                      secondRingColor: Colors.white,
                      thirdRingColor: Colors.blueAccent,
                      size: 30,
                    ),
                  );
                }
                List<Widget> messageWidget = [];
                var messages = snapshot.data?.docs.reversed;
                for (var message in messages!) {
                  isMe = (message['email'] == FirebaseAuth.instance.currentUser?.email);
                  messageWidget.add(
                    ChatBubble(
                      text: message['text'],
                      sender: sender,
                      checkSender: isMe,
                    ),
                  );
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    children: messageWidget,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.clear();
                      // FirebaseFirestore.instance.collection('messages').add({
                      //   'text': message,
                      //   'email' : FirebaseAuth.instance.currentUser?.email,
                      //   'sender': sender,
                      //   'timestamp': FieldValue.serverTimestamp(),
                      // });
                      FirebaseFirestore.instance.collection('messages').doc(chatId).collection('message').add({
                        'text': message,
                          'email' : FirebaseAuth.instance.currentUser?.email,
                          'sender': sender,
                          'timestamp': FieldValue.serverTimestamp(),
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

