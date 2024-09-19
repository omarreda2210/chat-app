import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/widegts/chat_masgges.dart';
import 'package:chat_app/widegts/new_masgges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setpPouhNot() async {
    final fMC = FirebaseMessaging.instance;
    await fMC.requestPermission();
    fMC.subscribeToTopic('chat');
    final token = await fMC.getToken();
  }

  @override
  void initState() {
    super.initState();

    setpPouhNot();
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Chat app'),
        ),
        body: const Column(
          children: [
            Expanded(child: ChatMasgges()),
            NewMasgges(),
          ],
        ));
  }
}
