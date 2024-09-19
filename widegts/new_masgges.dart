import 'package:chat_app/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMasgges extends StatefulWidget {
  const NewMasgges({super.key});

  @override
  State<NewMasgges> createState() => _NewMasggesState();
}

class _NewMasggesState extends State<NewMasgges> {
  final masgeeController = TextEditingController();

  void despis() {
    masgeeController.dispose();
    super.dispose();
  }

  void sumbitMasgge() async {
    final enterdMasge = masgeeController.text;
    if (enterdMasge.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      "Text": enterdMasge,
      'created AT': Timestamp.now(),
      'UserID': user.uid,
      'username': userData.data()!['username'],
      'userimage': userData.data()!['userimage'],
    });

    masgeeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 40),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: 'senad a masgee.....'),
            controller: masgeeController,
          )),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: sumbitMasgge,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
