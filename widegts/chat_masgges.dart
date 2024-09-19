import 'package:chat_app/widegts/masgge_buble..dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMasgges extends StatelessWidget {
  const ChatMasgges({super.key});

  @override
  Widget build(BuildContext context) {
    final acceptdUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('created AT', descending: true)
            .snapshots(),
        builder: (ctx, chatsnapshot) {
          if (chatsnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatsnapshot.hasData || chatsnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("no masgees were found"));
          }
          if (chatsnapshot.hasError) {
            return const Center(
              child: Text('somsthieng went rong'),
            );
          }
          final loadedMasgees = chatsnapshot.data!.docs;
          return ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              itemCount: loadedMasgees.length,
              itemBuilder: (ctx, index) {
                final chatmasges = loadedMasgees[index].data();
                final nextChatmasge = index + 1 < loadedMasgees.length
                    ? loadedMasgees[index + 1].data()
                    : null;
                final currentChatMassegid = chatmasges['UserID'];
                final nextMassegeUserid =
                    nextChatmasge != null ? nextChatmasge['UserID'] : null;
                final nextMassegUserIsSame =
                    nextMassegeUserid == currentChatMassegid;
                if (nextMassegUserIsSame) {
                  return MessageBubble.next(
                    message: chatmasges['Text'],
                    isMe: acceptdUser.uid == currentChatMassegid,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatmasges['userimage'],
                    username: chatmasges['username'],
                    message: chatmasges['Text'],
                    isMe: acceptdUser.uid == currentChatMassegid,
                  );
                }
              });
        });
  }
}
