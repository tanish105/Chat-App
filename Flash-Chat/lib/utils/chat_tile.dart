import 'package:flutter/material.dart';
import 'package:flutterchat/screens/chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String dispName;
  final bool isGroup;
  final String receiverUid;
  final String senderUid;
  final String chatId;
  final TextEditingController _controller;

  const ChatTile(this.dispName, this.isGroup,this.receiverUid,this.senderUid, this.chatId, this._controller,{super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
      child: MaterialButton(
        onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(_controller, receiverUid, senderUid, chatId,dispName)));
        },
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: ClipOval(
                  child: isGroup?Image.asset(
                    'images/group.png',
                  ):Image.asset(
                    'images/single_user.png',
                  ),
                ),
              ),
            ),
            SizedBox(width: 20,),
            Expanded(
              flex: 3,
              child: Container(
                child: Text(dispName),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
