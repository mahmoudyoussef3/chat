import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final messageController = TextEditingController();
  @override
  void dispose() {
messageController.dispose();    super.dispose();
  }
  void submitMessage()async{
    final enteredMessage = messageController.text;
    final user = FirebaseAuth.instance.currentUser!;
    if(enteredMessage.trim().isEmpty){
      return;
    }

    FocusScope.of(context).unfocus();

    final userDataFromAuth = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'message' : messageController.text,
      'createdAt' : Timestamp.now(),
      'userId' :user.uid,
      'userName' : userDataFromAuth.data()!['userName'],
      'userImg' : userDataFromAuth.data()!['imgUrl']
    });
    messageController.clear();

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: 'Send a message...'),
          )
          ),
          IconButton(onPressed: submitMessage, icon: Icon(Icons.send,color: Theme.of(context).colorScheme.primary,))
        ],
      ),
    );
  }
}
