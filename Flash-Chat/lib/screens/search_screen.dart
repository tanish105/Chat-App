import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/screens/chat_screen.dart';
import 'package:flutterchat/screens/search_screen.dart';
import 'package:flutterchat/screens/welcome_screen.dart';
import '../utils/chat_tile.dart';

class SearchContact extends StatefulWidget {
  const SearchContact({Key? key}) : super(key: key);

  @override
  State<SearchContact> createState() => _SearchContactState();
}

class _SearchContactState extends State<SearchContact> {
  late Map<String, dynamic> userMap;
  bool isLoading = false;
  bool isEmpty = true;
  TextEditingController _controller = TextEditingController();
  late List<Widget> chats = [];

  late Size size = MediaQuery.of(context).size;

  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    super.dispose();
  }

  String chatId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
    });
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try{
      await _firestore
          .collection('users')
          .where("Name", isEqualTo: _search.text)
          .get()
          .then((value) => {
        setState(() {
          userMap = value.docs[0].data();
        })
      });

      // setState(() {
      //   isLoading = false;
      // });

      setState(() {
        isLoading = false;
        chats.add(ChatTile(
            userMap['Name'],
            false,
            userMap['uid'],
            FirebaseAuth.instance.currentUser!.uid,
            chatId(
              FirebaseAuth.instance.currentUser!.uid,
              userMap['uid'],
            ),
            _controller));
        isEmpty = false;
      });
    } catch(e){
      showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            content: Container(
              child: const Text("User not found!"),
            ),
          );
        },
      );
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // await FirebaseAuth.instance.signOut();
                  // final user = FirebaseAuth.instance.currentUser;
                  // if (user == null) {
                  //   Navigator.pushNamed(context, WelcomeScreen.id);
                  // } else {
                  //   throw ("Invalid Request");
                  // }
                  Navigator.pop(context);
                }),
          ],
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Row(
              children: const [
                Text("Search - "),
              ],
            ),
          ),
          backgroundColor: Colors.lightBlueAccent,
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15),),),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height / 30,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                      hintText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 40,
            ),
            MaterialButton(
              onPressed: onSearch,
              color: Colors.lightBlueAccent,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            Expanded(
              child: isEmpty == false
                  ? ListView(
                      children: chats,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
