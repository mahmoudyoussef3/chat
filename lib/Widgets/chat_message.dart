import 'package:chat_max/Widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  const ChatMessage({super.key});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  void setupNotifications()async{
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
    // final token = await fcm.getToken();
    // print("token is$token nothimg more");
  }
  @override
  void initState() {
    super.initState();
    setupNotifications();
  }
  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Messages Found"),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something Went Wrong"),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageId = chatMessage['userId'];
            final nextMessageUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessage['message'],
                  isMe: authUser.uid == currentMessageId);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage['userImg'],
                  username: chatMessage['userName'],
                  message: chatMessage['message'],
                  isMe: authUser.uid == currentMessageId);
            }
          },
          itemCount: loadedMessages.length,
        );
      },
    );
  }
}
