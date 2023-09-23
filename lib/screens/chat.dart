import 'package:chat_max/Widgets/chat_message.dart';
import 'package:chat_max/Widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
        title: const Text('My Chat App'),
      ),
      body: const Column(children:[
     Expanded(child:    ChatMessage(),
     ),  NewMessage()
      ],)
    );
  }
}
